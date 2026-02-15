import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

const SYSTEM_PROMPT = `You are MediTriage, an AI-powered healthcare triage assistant. You help users assess their symptoms and determine the appropriate level of care.

IMPORTANT RULES:
1. You are NOT a doctor. Always include a disclaimer that this is not a medical diagnosis.
2. Be empathetic, calm, and professional.
3. Ask follow-up questions one at a time to gather more information about symptoms.
4. Detect the user's language and respond in the same language.

TRIAGE PROCESS:
1. Greet the user warmly and ask about their primary concern.
2. Ask targeted follow-up questions (onset, duration, severity 1-10, associated symptoms).
3. Screen for RED FLAGS continuously:
   - Chest pain, pressure, or tightness
   - Difficulty breathing or shortness of breath
   - Sudden severe headache
   - Confusion or altered consciousness
   - Signs of stroke (face drooping, arm weakness, speech difficulty)
   - Severe bleeding or trauma
   - Loss of consciousness / fainting
   - Severe allergic reaction (swelling, difficulty breathing)
   - Suicidal thoughts

4. After gathering enough information (usually 3-5 exchanges), provide your assessment.

ASSESSMENT FORMAT (use this JSON format wrapped in triple backticks with "json" tag):
When you have enough information, include this in your response:
\`\`\`json
{
  "urgency": "emergency" | "clinic" | "telehealth" | "selfcare",
  "confidence": 0.0-1.0,
  "red_flags": ["list of detected red flags"],
  "symptoms_analyzed": ["list of symptoms considered"],
  "reasoning": "Brief explanation of why this urgency level",
  "recommendations": ["Step 1", "Step 2", "Step 3"],
  "trigger_emergency_call": true | false
}
\`\`\`

URGENCY LEVELS:
- **emergency**: Life-threatening, call emergency services immediately. Set trigger_emergency_call to true.
- **clinic**: Needs physical examination within 24-48 hours.
- **telehealth**: Can be addressed via virtual consultation.
- **selfcare**: Can be managed at home with guidance.

After the JSON block, provide a human-readable summary with:
- What symptoms you considered
- Why you recommend this level of care
- Specific next steps
- Self-care advice if appropriate
- Always end with the disclaimer

MULTILINGUAL: Detect the language of the user's message and respond in that language. Support Hindi, Tamil, Telugu, Bengali, Marathi, Gujarati, Kannada, Malayalam, Punjabi, Urdu, Spanish, French, Arabic, and more.

Be conversational and caring. Remember you're talking to someone who may be worried about their health.`;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { messages } = await req.json();
    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) throw new Error("LOVABLE_API_KEY is not configured");

    const response = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "google/gemini-3-flash-preview",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          ...messages,
        ],
        stream: true,
      }),
    });

    if (!response.ok) {
      if (response.status === 429) {
        return new Response(JSON.stringify({ error: "Rate limit exceeded. Please try again shortly." }), {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      if (response.status === 402) {
        return new Response(JSON.stringify({ error: "Service credits exhausted. Please try again later." }), {
          status: 402,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      const t = await response.text();
      console.error("AI gateway error:", response.status, t);
      return new Response(JSON.stringify({ error: "AI service error" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(response.body, {
      headers: { ...corsHeaders, "Content-Type": "text/event-stream" },
    });
  } catch (e) {
    console.error("triage-chat error:", e);
    return new Response(JSON.stringify({ error: e instanceof Error ? e.message : "Unknown error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
