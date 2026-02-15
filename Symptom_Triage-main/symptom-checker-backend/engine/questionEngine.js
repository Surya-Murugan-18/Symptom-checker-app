function nextQuestion(state) {
  if (!state.symptoms.fever)
    return "Do you have fever? (yes/no)";

  if (!state.symptoms.fever_level)
    return "How high is your fever? (mild / moderate / high)";

  if (!state.symptoms.duration)
    return "How many days have you had these symptoms?";

  if (!state.symptoms.cough)
    return "Do you have cough? (yes/no)";

  if (state.symptoms.cough === "yes" && !state.symptoms.cough_type)
    return "Is your cough dry or wet?";

  if (!state.flags.breathing)
    return "Are you having any breathing difficulty? (yes/no)";

  return null; // Enough data
}

module.exports = { nextQuestion };
