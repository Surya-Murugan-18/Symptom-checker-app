package com.sevai.sevaibackend.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Configuration
public class DatabaseSchemaFixer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseSchemaFixer.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) throws Exception {
        try {
            logger.info("🛠️ Attempting to fix database schema for photo_url, is_online, and paid...");
            jdbcTemplate.execute("ALTER TABLE doctor ALTER COLUMN photo_url TYPE TEXT");

            // Manual check/addition for is_online to avoid NULL issues
            try {
                jdbcTemplate.execute("ALTER TABLE doctor ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT TRUE");
            } catch (Exception e) {
            }

            try {
                jdbcTemplate.execute("ALTER TABLE appointment ADD COLUMN IF NOT EXISTS paid BOOLEAN DEFAULT FALSE");
            } catch (Exception e) {
            }

            logger.info("✅ Successfully fixed database columns.");
        } catch (Exception e) {
            logger.warn("⚠️ Schema fix warning: " + e.getMessage());
        }

        try {
            logger.info("🛠️ Auto-verifying and setting online status for all doctors...");
            jdbcTemplate.execute("UPDATE doctor SET is_verified = TRUE WHERE is_verified IS NOT TRUE");
            jdbcTemplate.execute("UPDATE doctor SET is_online = TRUE");
            logger.info("✅ All doctors marked as Verified and Online.");
        } catch (Exception e) {
            logger.warn("⚠️ Verification fix warning: " + e.getMessage());
        }
    }
}
