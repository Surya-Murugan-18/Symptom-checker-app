import { useState, useRef, useEffect, useCallback } from "react";
import { Send, Mic, MicOff, Globe, Shield } from "lucide-react";
import { ChatMessage } from "@/components/ChatMessage";
import { TypingIndicator } from "@/components/TypingIndicator";
import { useVoiceInput } from "@/hooks/use-voice";
import { streamChat } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

type Msg = { role: "user" | "assistant"; content: string };

const LANGUAGES = [
  { code: "en-US", label: "English" },
  { code: "hi-IN", label: "हिंदी" },
  { code: "ta-IN", label: "தமிழ்" },
  { code: "te-IN", label: "తెలుగు" },
  { code: "bn-IN", label: "বাংলা" },
  { code: "es-ES", label: "Español" },
  { code: "fr-FR", label: "Français" },
  { code: "ar-SA", label: "العربية" },
];

export default function ChatInterface() {
  const [messages, setMessages] = useState<Msg[]>([]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [lang, setLang] = useState("en-US");
  const [showLangPicker, setShowLangPicker] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const { isListening, transcript, startListening, stopListening, resetTranscript } = useVoiceInput();
  const { toast } = useToast();

  useEffect(() => {
    if (transcript) setInput(transcript);
  }, [transcript]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, isLoading]);

  const send = useCallback(async (text: string) => {
    if (!text.trim() || isLoading) return;
    const userMsg: Msg = { role: "user", content: text.trim() };
    setMessages(prev => [...prev, userMsg]);
    setInput("");
    resetTranscript();
    setIsLoading(true);

    let assistantSoFar = "";
    const upsertAssistant = (chunk: string) => {
      assistantSoFar += chunk;
      setMessages(prev => {
        const last = prev[prev.length - 1];
        if (last?.role === "assistant") {
          return prev.map((m, i) => i === prev.length - 1 ? { ...m, content: assistantSoFar } : m);
        }
        return [...prev, { role: "assistant", content: assistantSoFar }];
      });
    };

    try {
      await streamChat({
        messages: [...messages, userMsg],
        onDelta: upsertAssistant,
        onDone: () => setIsLoading(false),
      });
    } catch (e: any) {
      setIsLoading(false);
      toast({ variant: "destructive", title: "Error", description: e.message || "Something went wrong" });
    }
  }, [messages, isLoading, resetTranscript, toast]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    send(input);
  };

  const toggleMic = () => {
    if (isListening) {
      stopListening();
      if (transcript) send(transcript);
    } else {
      startListening(lang);
    }
  };

  return (
    <div className="flex flex-col h-screen bg-background">
      {/* Header */}
      <header className="flex items-center justify-between px-4 md:px-6 py-3 border-b border-border bg-card shadow-card">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl gradient-hero flex items-center justify-center text-primary-foreground font-display font-bold text-lg">
            S
          </div>
          <div>
            <h1 className="font-display font-bold text-foreground text-lg leading-tight">Sevai</h1>
            <p className="text-xs text-muted-foreground">AI Health Assessment</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="relative">
            <button
              onClick={() => setShowLangPicker(!showLangPicker)}
              className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium bg-secondary text-secondary-foreground hover:bg-accent transition-colors"
            >
              <Globe className="w-3.5 h-3.5" />
              {LANGUAGES.find(l => l.code === lang)?.label}
            </button>
            {showLangPicker && (
              <div className="absolute right-0 top-full mt-1 bg-card border border-border rounded-lg shadow-card z-50 min-w-[140px]">
                {LANGUAGES.map(l => (
                  <button
                    key={l.code}
                    onClick={() => { setLang(l.code); setShowLangPicker(false); }}
                    className={`block w-full text-left px-3 py-2 text-sm hover:bg-accent transition-colors first:rounded-t-lg last:rounded-b-lg ${lang === l.code ? "text-primary font-semibold" : "text-foreground"}`}
                  >
                    {l.label}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 md:px-6 py-4 space-y-4">
        {messages.length === 0 && (
          <div className="flex flex-col items-center justify-center h-full text-center space-y-4 py-12">
            <div className="w-20 h-20 rounded-2xl gradient-hero flex items-center justify-center animate-pulse-ring">
              <Shield className="w-10 h-10 text-primary-foreground" />
            </div>
            <div>
              <h2 className="font-display font-bold text-xl text-foreground">Welcome to Sevai</h2>
              <p className="text-muted-foreground text-sm mt-1 max-w-md">
                Describe your symptoms and I'll help assess the urgency level. I support voice input and multiple languages.
              </p>
            </div>
            <div className="flex flex-wrap gap-2 justify-center max-w-md">
              {["I have a headache", "Chest pain", "Fever and cough", "मुझे बुखार है"].map(s => (
                <button
                  key={s}
                  onClick={() => send(s)}
                  className="px-3 py-1.5 rounded-full text-xs font-medium bg-accent text-accent-foreground hover:bg-primary hover:text-primary-foreground transition-colors"
                >
                  {s}
                </button>
              ))}
            </div>
            <p className="text-[10px] text-muted-foreground mt-4 flex items-center gap-1">
              <Shield className="w-3 h-3" /> This is not a medical diagnosis. Always consult a healthcare professional.
            </p>
          </div>
        )}

        {messages.map((m, i) => (
          <ChatMessage key={i} role={m.role} content={m.content} />
        ))}

        {isLoading && messages[messages.length - 1]?.role === "user" && <TypingIndicator />}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="border-t border-border bg-card px-4 md:px-6 py-3">
        <form onSubmit={handleSubmit} className="flex items-center gap-2 max-w-3xl mx-auto">
          <button
            type="button"
            onClick={toggleMic}
            className={`p-2.5 rounded-xl transition-all shrink-0 ${
              isListening
                ? "bg-destructive text-destructive-foreground animate-pulse-ring"
                : "bg-secondary text-secondary-foreground hover:bg-accent"
            }`}
          >
            {isListening ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
          </button>

          <input
            type="text"
            value={input}
            onChange={e => setInput(e.target.value)}
            placeholder={isListening ? "Listening..." : "Describe your symptoms..."}
            className="flex-1 bg-secondary text-foreground placeholder:text-muted-foreground rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-ring"
            disabled={isLoading}
          />

          <button
            type="submit"
            disabled={!input.trim() || isLoading}
            className="p-2.5 rounded-xl gradient-hero text-primary-foreground disabled:opacity-40 transition-opacity shrink-0"
          >
            <Send className="w-5 h-5" />
          </button>
        </form>
        <p className="text-[10px] text-center text-muted-foreground mt-2">
          ⚕️ Not a substitute for professional medical advice. In emergencies, call your local emergency number.
        </p>
      </div>
    </div>
  );
}
