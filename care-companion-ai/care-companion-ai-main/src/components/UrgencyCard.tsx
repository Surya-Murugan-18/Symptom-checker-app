import { AlertTriangle, Phone } from "lucide-react";
import { triggerEmergencyCall } from "@/lib/api";
import { useState } from "react";

interface UrgencyCardProps {
  urgency: string;
  confidence: number;
  redFlags: string[];
  symptomsAnalyzed: string[];
  reasoning: string;
  recommendations: string[];
  triggerCall: boolean;
}

const urgencyConfig: Record<string, { label: string; colorClass: string; icon: string }> = {
  emergency: { label: "🚨 Emergency Care", colorClass: "bg-urgency-emergency text-destructive-foreground", icon: "🚑" },
  clinic: { label: "🏥 Clinic Visit", colorClass: "bg-urgency-clinic text-destructive-foreground", icon: "🏥" },
  telehealth: { label: "📱 Telehealth", colorClass: "bg-urgency-telehealth text-foreground", icon: "📱" },
  selfcare: { label: "🏠 Self-Care", colorClass: "bg-urgency-selfcare text-destructive-foreground", icon: "💚" },
};

export function UrgencyCard({ urgency, confidence, redFlags, symptomsAnalyzed, reasoning, recommendations, triggerCall }: UrgencyCardProps) {
  const [callTriggered, setCallTriggered] = useState(false);
  const [calling, setCalling] = useState(false);
  const config = urgencyConfig[urgency] || urgencyConfig.selfcare;

  const handleEmergencyCall = async () => {
    setCalling(true);
    try {
      await triggerEmergencyCall(symptomsAnalyzed, urgency);
      setCallTriggered(true);
    } catch (e) {
      console.error(e);
    } finally {
      setCalling(false);
    }
  };

  return (
    <div className="rounded-lg border border-border overflow-hidden animate-slide-up shadow-card my-2">
      <div className={`px-4 py-3 font-display font-semibold text-sm ${config.colorClass}`}>
        {config.label} — {Math.round(confidence * 100)}% confidence
      </div>

      <div className="p-4 bg-card space-y-3 text-sm">
        {redFlags.length > 0 && (
          <div className="flex items-start gap-2 p-3 rounded-md bg-destructive/10 text-destructive">
            <AlertTriangle className="w-4 h-4 mt-0.5 shrink-0" />
            <div>
              <p className="font-semibold">Red Flags Detected</p>
              <p>{redFlags.join(", ")}</p>
            </div>
          </div>
        )}

        <div>
          <p className="font-semibold text-foreground mb-1">Why this recommendation:</p>
          <p className="text-muted-foreground">{reasoning}</p>
        </div>

        <div>
          <p className="font-semibold text-foreground mb-1">Next Steps:</p>
          <ol className="list-decimal list-inside text-muted-foreground space-y-1">
            {recommendations.map((r, i) => <li key={i}>{r}</li>)}
          </ol>
        </div>

        {triggerCall && urgency === "emergency" && (
          <button
            onClick={handleEmergencyCall}
            disabled={callTriggered || calling}
            className="w-full flex items-center justify-center gap-2 py-3 rounded-lg gradient-emergency text-destructive-foreground font-semibold text-sm transition-opacity hover:opacity-90 disabled:opacity-50"
          >
            <Phone className="w-4 h-4" />
            {callTriggered ? "Emergency Call Triggered ✓" : calling ? "Calling..." : "Trigger Emergency Call"}
          </button>
        )}
      </div>
    </div>
  );
}
