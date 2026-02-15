package com.sevai.sevaibackend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String firstName;
    private String lastName;
    private String email;

    @JsonIgnore
    private String password;

    private String gender;
    private String dob;
    private String location;
    private String contact;

    // ✅ ABOUT YOU FIELDS
    private String language;
    private Boolean hasChronicIllness;
    @Column(columnDefinition = "TEXT")
    private String chronicIllnessDetails;
    private Boolean takesRegularMedicine;
    private String weight;
    private String bloodPressureLevel;
    @Column(columnDefinition = "TEXT")
    private String photoUrl;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private java.util.List<EmergencyContact> emergencyContacts;

    // MEDFRIEND / CAREGIVER
    private String medfriendName;
    private String medfriendContact;
    private String medfriendEmail;

    // ===== GETTERS & SETTERS =====
    public String getMedfriendName() {
        return medfriendName;
    }

    public void setMedfriendName(String medfriendName) {
        this.medfriendName = medfriendName;
    }

    public String getMedfriendContact() {
        return medfriendContact;
    }

    public void setMedfriendContact(String medfriendContact) {
        this.medfriendContact = medfriendContact;
    }

    public String getMedfriendEmail() {
        return medfriendEmail;
    }

    public void setMedfriendEmail(String medfriendEmail) {
        this.medfriendEmail = medfriendEmail;
    }

    public java.util.List<EmergencyContact> getEmergencyContacts() {
        return emergencyContacts;
    }

    public void setEmergencyContacts(java.util.List<EmergencyContact> emergencyContacts) {
        this.emergencyContacts = emergencyContacts;
    }

    public Long getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public Boolean getHasChronicIllness() {
        return hasChronicIllness;
    }

    public void setHasChronicIllness(Boolean hasChronicIllness) {
        this.hasChronicIllness = hasChronicIllness;
    }

    public String getChronicIllnessDetails() {
        return chronicIllnessDetails;
    }

    public void setChronicIllnessDetails(String chronicIllnessDetails) {
        this.chronicIllnessDetails = chronicIllnessDetails;
    }

    public Boolean getTakesRegularMedicine() {
        return takesRegularMedicine;
    }

    public void setTakesRegularMedicine(Boolean takesRegularMedicine) {
        this.takesRegularMedicine = takesRegularMedicine;
    }

    public String getWeight() {
        return weight;
    }

    public void setWeight(String weight) {
        this.weight = weight;
    }

    public String getBloodPressureLevel() {
        return bloodPressureLevel;
    }

    public void setBloodPressureLevel(String bloodPressureLevel) {
        this.bloodPressureLevel = bloodPressureLevel;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }
}
