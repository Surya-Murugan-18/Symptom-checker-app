import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { symptoms, urgency } = await req.json();

    const TWILIO_SID = Deno.env.get("TWILIO_SID");
    const TWILIO_AUTH = Deno.env.get("TWILIO_AUTH");
    const TWILIO_NUMBER = Deno.env.get("TWILIO_NUMBER");
    const EMERGENCY_NUMBER = Deno.env.get("EMERGENCY_NUMBER");

    if (!TWILIO_SID || !TWILIO_AUTH || !TWILIO_NUMBER || !EMERGENCY_NUMBER) {
      throw new Error("Twilio credentials not configured");
    }

    const symptomList = Array.isArray(symptoms) ? symptoms.join(", ") : "critical symptoms detected";

    const twiml = `
      <Response>
        <Say voice="Polly.Joanna">
          This is an emergency alert from the MediTriage system.
          A patient has reported ${symptomList}.
          The urgency level is ${urgency || "emergency"}.
          Please respond immediately.
        </Say>
        <Pause length="1"/>
        <Say voice="Polly.Joanna">
          Repeating: Emergency alert. Patient symptoms include ${symptomList}.
          Immediate medical attention is required.
        </Say>
      </Response>
    `;

    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_SID}/Calls.json`;

    const params = new URLSearchParams();
    params.append("To", EMERGENCY_NUMBER);
    params.append("From", TWILIO_NUMBER);
    params.append("Twiml", twiml);

    const response = await fetch(twilioUrl, {
      method: "POST",
      headers: {
        "Authorization": "Basic " + btoa(`${TWILIO_SID}:${TWILIO_AUTH}`),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params.toString(),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Twilio error:", data);
      return new Response(JSON.stringify({ success: false, error: data.message || "Failed to trigger call" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: true, callSid: data.sid }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("trigger-emergency error:", e);
    return new Response(JSON.stringify({ success: false, error: e instanceof Error ? e.message : "Unknown error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
