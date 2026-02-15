function nextFeverQuestion(state) {

  if (state.duration_days === undefined) {
    state.last_question = "duration_days";
    return "Since when are you having fever? (in days)";
  }

  if (state.fever_level === undefined) {
    state.last_question = "fever_level";
    return "Do you know your temperature, or does it feel mild (99–101), moderate (101–103), or high (>103)?";
  }

  if (state.chills === undefined) {
    state.last_question = "chills";
    return "Are you having chills or shivering? (yes/no)";
  }

  if (state.body_pain === undefined) {
    state.last_question = "body_pain";
    return "Do you have body pain or joint pain? (yes/no)";
  }

  if (state.breathing === undefined) {
    state.last_question = "breathing";
    return "Are you having any breathing difficulty or chest discomfort? (yes/no)";
  }

  state.last_question = null;
  return null; // Enough data
}

module.exports = { nextFeverQuestion };
