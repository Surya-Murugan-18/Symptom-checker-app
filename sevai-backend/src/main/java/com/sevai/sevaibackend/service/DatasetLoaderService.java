package com.sevai.sevaibackend.service;

import com.opencsv.CSVReader;
import com.sevai.sevaibackend.entity.Disease;
import com.sevai.sevaibackend.entity.Symptom;
import com.sevai.sevaibackend.repository.DiseaseRepository;
import com.sevai.sevaibackend.repository.SymptomRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.InputStreamReader;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DatasetLoaderService {

    private final DiseaseRepository diseaseRepository;
    private final SymptomRepository symptomRepository;
    private final ResourceLoader resourceLoader;

    private Map<String, Symptom> symptomCache;
    private Map<String, Disease> diseaseCache;

    @PostConstruct
    @Transactional
    public void loadDatasets() {
        log.info("Checking for medical datasets...");

        initializeCaches();

        loadSymptoms();
        loadDiseaseDescriptions();
        loadDiseasePrecautions();
        loadTrainingData();

        log.info("Dataset loading complete. Saving changes...");
    }

    private void initializeCaches() {
        log.info("Initializing in-memory caches...");
        symptomCache = symptomRepository.findAll().stream()
                .collect(Collectors.toMap(Symptom::getName, Function.identity()));
        diseaseCache = diseaseRepository.findAll().stream()
                .collect(Collectors.toMap(Disease::getName, Function.identity()));
        log.info("Loaded {} symptoms and {} diseases into cache.", symptomCache.size(), diseaseCache.size());
    }

    private void loadSymptoms() {
        try {
            Resource resource = resourceLoader.getResource("classpath:datasets/symptom_severity.csv");
            if (!resource.exists())
                return;

            try (CSVReader reader = new CSVReader(new InputStreamReader(resource.getInputStream()))) {
                String[] line;
                reader.readNext(); // Skip header
                while ((line = reader.readNext()) != null) {
                    if (line.length < 2)
                        continue;
                    String name = line[0].trim().replace("_", " "); // Normalize name
                    int weight = parseInteger(line[1]);

                    if (!symptomCache.containsKey(name)) {
                        Symptom symptom = Symptom.builder().name(name).weight(weight).build();
                        symptom = symptomRepository.save(symptom);
                        symptomCache.put(name, symptom);
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error loading symptoms: {}", e.getMessage());
        }
    }

    private void loadDiseaseDescriptions() {
        try {
            Resource resource = resourceLoader.getResource("classpath:datasets/symptom_Description.csv");
            if (!resource.exists())
                return;

            try (CSVReader reader = new CSVReader(new InputStreamReader(resource.getInputStream()))) {
                String[] line;
                reader.readNext(); // Skip header
                while ((line = reader.readNext()) != null) {
                    if (line.length < 2)
                        continue;
                    String name = line[0].trim();
                    String description = line[1].trim();

                    Disease disease = getOrCreateDisease(name);
                    if (disease.getDescription() == null || disease.getDescription().isEmpty()) {
                        disease.setDescription(description);
                        disease = diseaseRepository.save(disease);
                        diseaseCache.put(name, disease);
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error loading disease descriptions: {}", e.getMessage());
        }
    }

    private void loadDiseasePrecautions() {
        try {
            Resource resource = resourceLoader.getResource("classpath:datasets/symptom_precaution.csv");
            if (!resource.exists())
                return;

            try (CSVReader reader = new CSVReader(new InputStreamReader(resource.getInputStream()))) {
                String[] line;
                reader.readNext(); // Skip header
                while ((line = reader.readNext()) != null) {
                    if (line.length < 2)
                        continue;
                    String name = line[0].trim();

                    Disease disease = getOrCreateDisease(name);

                    Set<String> precautions = new HashSet<>();
                    for (int i = 1; i < line.length; i++) {
                        String precaution = line[i].trim();
                        if (!precaution.isEmpty()) {
                            precautions.add(precaution);
                        }
                    }

                    if (!precautions.isEmpty()) {
                        disease.setPrecautions(precautions);
                        disease = diseaseRepository.save(disease);
                        diseaseCache.put(name, disease);
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error loading disease precautions: {}", e.getMessage());
        }
    }

    private void loadTrainingData() {
        try {
            Resource resource = resourceLoader.getResource("classpath:datasets/Training.csv");
            if (!resource.exists())
                return;

            try (CSVReader reader = new CSVReader(new InputStreamReader(resource.getInputStream()))) {
                String[] line;
                reader.readNext();
                while ((line = reader.readNext()) != null) {
                    if (line.length < 2)
                        continue;
                    String diseaseName = line[0].trim();

                    Disease disease = getOrCreateDisease(diseaseName);
                    boolean changed = false;

                    for (int i = 1; i < line.length; i++) {
                        String symptomName = line[i].trim().replace("_", " ");
                        if (symptomName.isEmpty())
                            continue;

                        Symptom symptom = getOrCreateSymptom(symptomName);
                        if (!disease.getSymptoms().contains(symptom)) {
                            disease.getSymptoms().add(symptom);
                            changed = true;
                        }
                    }

                    if (changed) {
                        disease = diseaseRepository.save(disease);
                        diseaseCache.put(diseaseName, disease);
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error loading training data: {}", e.getMessage());
        }
    }

    private Disease getOrCreateDisease(String name) {
        if (diseaseCache.containsKey(name)) {
            return diseaseCache.get(name);
        }
        Disease disease = Disease.builder().name(name).build();
        disease = diseaseRepository.save(disease);
        diseaseCache.put(name, disease);
        return disease;
    }

    private Symptom getOrCreateSymptom(String name) {
        if (symptomCache.containsKey(name)) {
            return symptomCache.get(name);
        }
        Symptom symptom = Symptom.builder().name(name).weight(1).build();
        symptom = symptomRepository.save(symptom);
        symptomCache.put(name, symptom);
        return symptom;
    }

    private int parseInteger(String val) {
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return 1;
        }
    }
}
