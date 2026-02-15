/*
  SEV-AI ESP32 Health Data Simulator
  Sends simulated health data to the Spring Boot backend via WiFi.
  
  Setup:
  1. Install ESP32 board in Arduino IDE.
  2. Update SSID and Password below.
  3. Update SERVER_IP to your computer's IP address.
  4. Update USER_EMAIL to your registered email in the app.
*/

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// WiFi Credentials
const char* ssid = "MG 9706"; // <-- UPDATE THIS
const char* password = "4691Tc2#"; // <-- UPDATE THIS

// Backend Configuration
// Use your computer's local IP (e.g., 10.93.84.101)
const char* serverUrl = "http://192.168.137.231:8081/api/health/push";
const char* userEmail = "suryasit2027@gmail.com"; // Change to your registered email

void setup() {
  Serial.begin(115200);
  
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");

    // Generate simulated data
    int hr = random(65, 95);     // 65-95 bpm
    int spo2 = random(95, 100);  // 95-100 %
    float temp = 97.5 + (random(0, 20) / 10.0); // 97.5 - 99.5 F
    int steps = random(1000, 10000);
    int resp = random(12, 20);

    // Create JSON payload
    StaticJsonDocument<200> doc;
    doc["email"] = userEmail;
    doc["heartRate"] = hr;
    doc["spo2"] = spo2;
    doc["temperature"] = temp;
    doc["steps"] = steps;
    doc["respiratoryRate"] = resp;

    String requestBody;
    serializeJson(doc, requestBody);

    int httpResponseCode = http.POST(requestBody);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Data Sent! HTTP Code: " + String(httpResponseCode));
      Serial.println("Response: " + response);
    } else {
      Serial.print("Error sending POST: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  }

  // Send data every 5 seconds
  delay(5000);
}
