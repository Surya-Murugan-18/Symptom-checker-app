const express = require("express");
const { v4: uuid } = require("uuid");

const { getSession } = require("../engine/stateManager");
const { updateFeverState } = require("../engine/feverStateUpdater");
const { nextFeverQuestion } = require("../engine/feverQuestionEngine");
const { classifyFever } = require("../engine/feverRuleEngine");

const router = express.Router();

router.post("/", (req, res) => {
  const sessionId = req.body.sessionId || uuid();
  const userMessage = req.body.message;

  const state = getSession(sessionId);

  // 🔥 FEVER STATE UPDATE
  updateFeverState(state, userMessage);

  // 🔥 FEVER QUESTION FLOW
  const question = nextFeverQuestion(state);

  if (question) {
    return res.json({
      sessionId,
      type: "question",
      message: question
    });
  }

  // 🔥 FEVER TRIAGE
  const result = classifyFever(state);

  return res.json({
    sessionId,
    type: "triage",
    triage: result,
    data: buildFeverResponse(result, state)
  });
});

function buildFeverResponse(type, state) {
  if (type === "self_care") {
    return {
      title: "Likely Mild Fever",
      subtitle: "Based on your answers",
      explanation:
        "Your fever appears mild to moderate, short in duration, and without danger signs.",
      homeCareTips: [
        "Take adequate rest",
        "Drink plenty of fluids",
        "Use paracetamol if needed"
      ],
      warningSigns: [
        "Fever above 103°F",
        "Breathing difficulty",
        "Rash or severe weakness"
      ],
      footer: "This is not a medical diagnosis."
    };
  }

  if (type === "doctor") {
    return {
      title: "Doctor Visit Recommended",
      subtitle: "Persistent fever needs evaluation",
      explanation:
        "Moderate fever lasting more than 2–3 days should be evaluated by a doctor.",
      specialty: "General Physician",
      footer: "Clinic information shown is for demonstration purposes only."
    };
  }

  return {
    title: "Emergency Action Required",
    subtitle: "Possible serious condition",
    emergencyMessage:
      "High fever or danger signs detected. Seek emergency care immediately.",
    actions: ["Call ambulance", "Go to nearest hospital"],
    footer: "Guidance based on public medical guidelines."
  };
}

module.exports = router;
