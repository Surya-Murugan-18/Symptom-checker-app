import ReactMarkdown from "react-markdown";
import { Volume2 } from "lucide-react";
import { speakText } from "@/hooks/use-voice";
import { UrgencyCard } from "./UrgencyCard";
import { useMemo } from "react";

interface ChatMessageProps {
  role: "user" | "assistant";
  content: string;
}

function extractTriageJSON(content: string) {
  const match = content.match(/```json\s*([\s\S]*?)```/);
  if (!match) return null;
  try {
    return JSON.parse(match[1]);
  } catch {
    return null;
  }
}

function stripTriageJSON(content: string) {
  return content.replace(/```json\s*[\s\S]*?```/, "").trim();
}

export function ChatMessage({ role, content }: ChatMessageProps) {
  const triageData = useMemo(() => role === "assistant" ? extractTriageJSON(content) : null, [role, content]);
  const displayContent = useMemo(() => role === "assistant" ? stripTriageJSON(content) : content, [role, content]);

  const isUser = role === "user";

  return (
    <div className={`flex ${isUser ? "justify-end" : "justify-start"} animate-slide-up`}>
      <div className={`max-w-[85%] md:max-w-[75%] rounded-2xl px-4 py-3 ${
        isUser
          ? "bg-chat-user text-chat-user-foreground rounded-br-md"
          : "bg-chat-bot text-chat-bot-foreground rounded-bl-md shadow-chat"
      }`}>
        {isUser ? (
          <p className="text-sm">{displayContent}</p>
        ) : (
          <div className="space-y-2">
            <div className="prose prose-sm max-w-none prose-p:my-1 prose-li:my-0.5 text-chat-bot-foreground">
              <ReactMarkdown>{displayContent}</ReactMarkdown>
            </div>

            {triageData && (
              <UrgencyCard
                urgency={triageData.urgency}
                confidence={triageData.confidence}
                redFlags={triageData.red_flags || []}
                symptomsAnalyzed={triageData.symptoms_analyzed || []}
                reasoning={triageData.reasoning || ""}
                recommendations={triageData.recommendations || []}
                triggerCall={triageData.trigger_emergency_call || false}
              />
            )}

            <button
              onClick={() => speakText(displayContent)}
              className="flex items-center gap-1 text-xs text-muted-foreground hover:text-primary transition-colors mt-1"
            >
              <Volume2 className="w-3 h-3" /> Listen
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
