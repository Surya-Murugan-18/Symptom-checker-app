# Localization Audit – All 6 Languages (Tamil, English, Hindi, Telugu, Malayalam, Marathi)

This file tracks which screens use **AppStrings.s()** so every user-visible string follows the selected language.  
**Rule:** Any screen that shows text to the patient must use `AppStrings.s(key, fallback)` (no hardcoded English).

---

## ✅ Fully localized (using AppStrings.s or equivalent for all UI text)

| Screen | File | Notes |
|--------|------|--------|
| Login | `login.dart` | AppStrings.s for headings, buttons |
| User role | `userrole.dart` | AppStrings.s for title, subtitle, roles, footer |
| Loading | `loadingpage.dart` | AppStrings.s for description |
| Home | `homepage.dart` | AppStrings.s for all labels, features, emergency popup |
| Schedule | `schedule.dart` | AppStrings.s for title, tabs, status badges, buttons, emergency popup |
| Find Doctor | `finddoctor.dart` | AppStrings.s for title, category, search hint, category labels, recommended/recent |
| Doctor Detail | `doctordetail.dart` | AppStrings.s for title, experience, about, book/reschedule, snackbar, chip |
| Booking Doctor | `bookingdoctor.dart` | AppStrings.s for all labels, dialogs, payment, reason list |
| Chat Doctor | `chatdoctor.dart` | AppStrings.s for payment dialog, type hint, You, Online |
| Video Call | `video_call_page.dart` | AppStrings.s for title, back, error, video/voice labels |
| Message | `message.dart` | AppStrings.s for header, empty state, emergency popup |
| Profile | `profile.dart` | AppStrings.s for menu items, vitals, logout, emergency |
| Safety Information | `safety_information.dart` | AppStrings.s for all content |
| About SEV-AI | `about_sev-ai.dart` | AppStrings.s for all content |
| Medication Reminder | `medication remainder.dart` | AppStrings.s for title, subtitle, features, disclaimer |
| Insurance (intro) | `insurance1.dart` | AppStrings.s for title, description, info box, buttons, footer |
| Notifications | `notification.dart` | AppStrings.s for title, filter, date, empty state, today/yesterday, snackbar |
| Ambulance | `ambulance.dart` | AppStrings.s for title, search hint, confirm address, confirm location, dialog |
| Nearby Hospital | `nearby_hospital.dart` | AppStrings.s for call dialog, OK |
| Help | `help.dart` | AppStrings.s for title, tabs, FAQ items |

---

## 🔶 Partially localized (uses app_strings but some hardcoded text may remain)

| Screen | File | Action |
|--------|------|--------|
| Insurance 2–6 | `insurance2.dart` … `insurance6.dart` | Replace any remaining `strings['...']` or literals with AppStrings.s() |
| Medication 2, 3, 4, 5, history, edit, pill remainder | Various | Audit each for Text('...') and add keys + AppStrings.s() |
| Health monitoring 1–8 | `health monitotring 1.dart` … `8.dart` | Same |
| OCR (scan, done, analyse, nextstep, notes, summary, intro, report) | Various | Same |
| Sign in | `signin.dart` | Ensure all labels/hints/buttons use AppStrings.s() |
| Sign up | `signup.dart` | Same |
| Forget password | `forget_password.dart` | Same |
| Reset password | `resetpassword.dart` | Same |
| New password | `newpassword.dart` | Same |
| Success | `successfull.dart` | Same |
| About you | `about_you_page.dart` | Same |
| Emergency contact | `emergency_contact_page.dart` | Same |
| Edit profile | `edit_profile.dart`, `edit profile .dart` | Same |
| Articles / expand | `articles.dart`, `artcile_expand.dart` | Same |
| Top Doctor | `top_doctor.dart` | Same |
| Terms & Conditions | `terms_and_conditions.dart` | Already uses strings; switch to AppStrings.s() for fallback |
| Privacy Policy | `privacy_policy.dart` | Same |
| Privacy & Notifications | `privacy_notifications.dart` | Same |
| Account Login | `account_login.dart` | Same |
| Health assessments | `health_assements.dart` | Same |
| Emergency classification / Doctor visit / Self-care urgency | `emergency_classification.dart`, etc. | Audit and add AppStrings.s() |
| Disease | `disease.dart` | Same |
| Language selection | `languageselection.dart` | Same |
| Chatscreen (AI chat) | `chatscreen.dart` | Same |
| Doctor chat detail | `doctor_chat_detail.dart` | Same |

---

## 🔷 Doctor-side screens (optional for patient-language goal)

Doctor dashboard, doctor booking, doctor consult, doctor notifications, doctor signin/signup, etc.  
Can be localized the same way if you want the app to support doctor UI in all 6 languages.

---

## How to finish the rest

1. Open each file under **Partially localized**.
2. Search for: `Text('`, `title: '`, `hintText: '`, `label: '`, `SnackBar(content: Text('`, etc.
3. For each literal string:
   - Add a key to `lib/language/app_strings.dart` (at least in **English**; add Tamil/Hindi/Telugu/Malayalam/Marathi for full 6-language support).
   - Replace the literal with `AppStrings.s('key', 'English fallback')`.
4. Re-run the app and switch language to confirm every screen follows the selected language.

---

## New keys added in this pass (for reference)

- **Booking / Doctor / Notification:**  
  `chat_now`, `notes_to_doctor`, `describe_symptoms_hint`, `payment_details`, `payment_method`, `consultation_fee`, `request_appointment`, `select_reason`, `general_consultation`, `follow_up_visit`, `fever_cold`, `physical_checkup`, `report_review`, `other_reason`, `date_label`, `time_label`, `reason_label`, `reschedule_success_snackbar`, `yrs_experience`, `could_not_load_appointment`  
  (Added in **Tamil** and **English**; other languages fall back to English until keys are added.)
