function updateState(state, message) {
  const msg = message.toLowerCase();

  if (msg.includes("fever")) state.symptoms.fever = "yes";
  if (["mild", "moderate", "high"].includes(msg))
    state.symptoms.fever_level = msg;

  if (msg.match(/\d+/))
    state.symptoms.duration = msg.match(/\d+/)[0];

  if (msg.includes("cough")) state.symptoms.cough = "yes";
  if (msg.includes("dry")) state.symptoms.cough_type = "dry";
  if (msg.includes("wet")) state.symptoms.cough_type = "wet";

  if (msg.includes("breath")) state.flags.breathing = "yes";
}

module.exports = { updateState };
