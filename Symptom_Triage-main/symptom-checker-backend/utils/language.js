function detectLanguage(text) {
  if (/[\u0B80-\u0BFF]/.test(text)) return "ta"; // Tamil
  if (/[\u0900-\u097F]/.test(text)) return "hi"; // Hindi
  return "en";
}

module.exports = { detectLanguage };
