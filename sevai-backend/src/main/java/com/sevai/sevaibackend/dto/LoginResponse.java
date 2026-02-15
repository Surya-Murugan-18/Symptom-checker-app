package com.sevai.sevaibackend.dto;

public class LoginResponse {
    public Long id;
    public String token;
    public String email;
    public String firstName;
    public String lastName;

    public String gender;
    public String dob;
    public String location;
    public String contact;
    public String language;
    public Boolean hasChronicIllness;
    public String chronicIllnessDetails;
    public Boolean takesRegularMedicine;
    public String weight;
    public String bloodPressureLevel;
    public String photoUrl;

    public LoginResponse(Long id, String token, String email, String firstName, String lastName) {
        this.id = id;
        this.token = token;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public java.util.List<EmergencyContactDTO> emergencyContacts;

    public static class EmergencyContactDTO {
        public Long id;
        public String name;
        public String phone;
        public String relation;
    }

    public LoginResponse(Long id, String token, String email, String firstName, String lastName,
            String gender, String dob, String location, String contact, String language,
            Boolean hasChronicIllness, String chronicIllnessDetails, Boolean takesRegularMedicine,
            String weight, String bloodPressureLevel, String photoUrl,
            java.util.List<EmergencyContactDTO> emergencyContacts) {
        this.id = id;
        this.token = token;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.gender = gender;
        this.dob = dob;
        this.location = location;
        this.contact = contact;
        this.language = language;
        this.hasChronicIllness = hasChronicIllness;
        this.chronicIllnessDetails = chronicIllnessDetails;
        this.takesRegularMedicine = takesRegularMedicine;
        this.weight = weight;
        this.bloodPressureLevel = bloodPressureLevel;
        this.photoUrl = photoUrl;
        this.emergencyContacts = emergencyContacts;
    }
}
