package com.sevai.sevaibackend.dto;

public class AboutYouRequest {

    private String language;
    private Boolean hasChronicIllness;
    private String chronicIllnessDetails;
    private Boolean takesRegularMedicine;

    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }

    public Boolean getHasChronicIllness() { return hasChronicIllness; }
    public void setHasChronicIllness(Boolean hasChronicIllness) {
        this.hasChronicIllness = hasChronicIllness;
    }

    public String getChronicIllnessDetails() { return chronicIllnessDetails; }
    public void setChronicIllnessDetails(String chronicIllnessDetails) {
        this.chronicIllnessDetails = chronicIllnessDetails;
    }

    public Boolean getTakesRegularMedicine() { return takesRegularMedicine; }
    public void setTakesRegularMedicine(Boolean takesRegularMedicine) {
        this.takesRegularMedicine = takesRegularMedicine;
    }
}
