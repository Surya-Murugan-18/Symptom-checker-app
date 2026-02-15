function updateFeverState(state, message) {
  const msg = message.toLowerCase().trim();

  // Handle numeric answers
  if (state.last_question === "duration_days") {
    const dayMatch = msg.match(/\d+/);
    if (dayMatch) state.duration_days = Number(dayMatch[0]);
    return;
  }

  // Handle fever level
  if (state.last_question === "fever_level") {
    if (msg.includes("mild") || msg.includes("99") || msg.includes("100"))
      state.fever_level = "mild";
    else if (msg.includes("moderate") || msg.includes("101") || msg.includes("102"))
      state.fever_level = "moderate";
    else if (msg.includes("high") || msg.includes("103") || msg.includes("104"))
      state.fever_level = "high";
    return;
  }

  // YES / NO mapping
  const yes = ["yes", "yeah", "y", "haan", "irukku"];
  const no = ["no", "nah", "n", "illa", "illai"];

  const isYes = yes.some(w => msg === w);
  const isNo = no.some(w => msg === w);

  if (!isYes && !isNo) return;

  if (state.last_question === "chills")
    state.chills = isYes;

  if (state.last_question === "body_pain")
    state.body_pain = isYes;

  if (state.last_question === "breathing")
    state.breathing = isYes;
}

module.exports = { updateFeverState };
