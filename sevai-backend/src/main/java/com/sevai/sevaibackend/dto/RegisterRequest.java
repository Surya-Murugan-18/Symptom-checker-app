package com.sevai.sevaibackend.dto;

import java.util.List;

public class RegisterRequest {
    public String firstName;
    public String lastName;
    public String email;
    public String password;
    public String gender;
    public String dob;
    public String location;
    public String contact;

    // Health Info
    public String language;
    public Boolean hasChronicIllness;
    public String chronicIllnessDetails;
    public Boolean takesRegularMedicine;
    public String weight;
    public String bloodPressureLevel;

    // Emergency Contacts
    public List<EmergencyContactRegisterDTO> emergencyContacts;

    public static class EmergencyContactRegisterDTO {
        public String name;
        public String phoneNumber;
        public String relationship;
    }
}
