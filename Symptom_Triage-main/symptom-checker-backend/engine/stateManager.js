const sessions = {};

function getSession(sessionId) {
  if (!sessions[sessionId]) {
    sessions[sessionId] = {
      duration_days: undefined,
      fever_level: undefined,
      chills: undefined,
      body_pain: undefined,
      breathing: undefined,
      rash: undefined,
      last_question: null
    };
  }
  return sessions[sessionId];
}

module.exports = { getSession };
