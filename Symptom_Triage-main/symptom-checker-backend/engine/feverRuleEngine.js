function classifyFever(state) {
  const { fever_level, duration_days, breathing, rash } = state;

  // 🔴 EMERGENCY
  if (
    fever_level === "high" ||
    breathing === true ||
    rash === true
  ) {
    return "emergency";
  }

  // 🟡 DOCTOR VISIT
  if (
    fever_level === "moderate" &&
    duration_days >= 3
  ) {
    return "doctor";
  }

  // 🟢 SELF CARE
  return "self_care";
}

module.exports = { classifyFever };
