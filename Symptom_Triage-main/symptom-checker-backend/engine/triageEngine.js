function classify(state) {
  const fever = state.symptoms.fever_level;
  const days = Number(state.symptoms.duration || 0);
  const breathing = state.flags.breathing === "yes";

  // 🚑 EMERGENCY
  if (fever === "high" || breathing) {
    return "emergency";
  }

  // 🏥 DOCTOR VISIT
  if (fever === "moderate" || days >= 3 || state.symptoms.cough_type === "wet") {
    return "doctor";
  }

  // 🏠 SELF CARE
  return "self_care";
}

module.exports = { classify };
