# Prescription Functionality Implementation

## Overview

This document describes the implementation of prescription functionality that fetches OPD appointments and their associated prescriptions using a two-tier API system.

## Architecture

### API Endpoints

1. **GET /api/Patients/my-opd-by-booklet/{bookletNo}**

   - Fetches list of OPD appointments for a specific booklet
   - Returns array of OPD objects with appointment details

2. **GET /api/Patients/my-prescriptions/{opdId}**
   - Fetches prescription details for a specific OPD appointment
   - Returns array of Prescription objects with medication details

Both endpoints require Bearer token authentication passed in the Authorization header.

## Implementation Details

### Models Created

#### 1. `lib/models/opd.dart`

Represents an OPD (Outpatient Department) appointment with 30 fields including:

- `opdid`: Unique appointment identifier
- `doctorCode`: Doctor assigned to the appointment
- `opdDate`: Date and time of the appointment
- `diagnosis`: Diagnosis notes
- `complaints`: Patient complaints
- `examination`: Examination notes
- And many more fields for comprehensive appointment tracking

#### 2. `lib/models/prescription.dart`

Represents a prescription with medication details:

- `prescriptionID`: Unique prescription identifier
- `appointmentID`: Associated OPD ID
- `opd`: Complete OPD object (nested)
- `drugName`: Name of the prescribed medication
- `drugSalt`: Generic salt composition
- `drugType`: Type (CAP, TAB, etc.)
- `dossage`: Dosage instructions
- `remark`: Special instructions
- `qty`: Quantity prescribed
- `issuedBy`: Who issued the prescription
- `issuedOn`: When it was issued

### Repository

#### `lib/repositories/prescription_repository.dart`

Handles API communication with debug logging:

- `getOpdsByBooklet(String token, String bookletNo)`: Fetches OPD list
- `getPrescriptionsByOpdId(String token, int opdId)`: Fetches prescription details

Includes comprehensive debug logging with emoji prefixes:

- 🔵 for API calls
- ✅ for success
- ❌ for errors

### BLoC (Business Logic Component)

#### Events (`lib/bloc/prescription_event.dart`)

- `PrescriptionLoadOpdList(bookletNo)`: Load OPD appointments
- `PrescriptionLoadDetails(opdId)`: Load prescription details for an OPD
- `PrescriptionReset`: Reset to initial state

#### States (`lib/bloc/prescription_state.dart`)

- `PrescriptionInitial`: Initial state
- `PrescriptionOpdListLoading`: Loading OPD list
- `PrescriptionOpdListLoaded`: OPD list loaded successfully
- `PrescriptionDetailsLoading`: Loading prescription details (preserves OPD list)
- `PrescriptionDetailsLoaded`: Prescription details loaded (includes OPD list)
- `PrescriptionError`: Error state with message

#### Bloc (`lib/bloc/prescription_bloc.dart`)

Manages prescription state with:

- Token validation and expiration checking
- Error handling with user-friendly messages
- State preservation (OPD list remains available when loading details)

### UI Implementation

#### 1. `lib/pages/prescription_page/prescription_page.dart`

**Features:**

- Fetches OPD list on page load using active booklet number
- Displays list of OPD appointments with:
  - Doctor name (with "Dr." prefix)
  - OPD ID
  - Formatted date and time
  - Diagnosis (if available)
- Click on any OPD card navigates to prescription details
- Loading states and error handling with snackbars
- Empty state message when no prescriptions found
- Search icon placeholder in app bar
- "Download All" button placeholder

**Date Formatting:**
Uses `intl` package to format dates as "MMM dd yyyy - hh:mm a" (e.g., "Sep 26 2025 - 07:39 AM")

#### 2. `lib/pages/prescription_page/prescription_details_page.dart`

**Features:**

- Fetches prescription details for selected OPD on page load
- Displays comprehensive OPD information:
  - Doctor name
  - OPD ID
  - Date and time
  - Diagnosis
  - Complaints (if available)
- Lists all prescribed medications with:
  - Drug name (bold heading)
  - Drug type and quantity tags (colored capsules)
  - Generic salt composition
  - Dosage instructions
  - Special remarks (highlighted in red)
  - Issued by information
- Floating "Download" button (placeholder)
- Loading states and error handling
- Empty state when no prescriptions found

### Configuration Updates

#### `lib/config/app_config.dart`

Added new endpoint methods:

- `opdByBookletUrl(String bookletNo)`: Returns full URL for OPD by booklet endpoint
- `prescriptionsByOpdUrl(int opdId)`: Returns full URL for prescriptions by OPD endpoint

Both use environment variables with fallback defaults.

#### Environment Variables (`.env` and `sample.env`)

Added:

```
API_OPD_BY_BOOKLET_ENDPOINT=/api/Patients/my-opd-by-booklet
API_PRESCRIPTIONS_BY_OPD_ENDPOINT=/api/Patients/my-prescriptions
```

### Dependency Management

#### `pubspec.yaml`

Added `intl: ^0.19.0` for date formatting.

#### `lib/main.dart`

Updated with:

- `PrescriptionBloc` provider
- `AuthRepository` as `RepositoryProvider` (for access in prescription pages)
- All prescription functionality integrated into app-wide BLoC providers

## Data Flow

### Loading OPD List

1. User navigates to Prescriptions page
2. Page retrieves active booklet number from `AuthRepository`
3. `PrescriptionBloc` receives `PrescriptionLoadOpdList` event
4. Bloc validates stored token and checks expiration
5. Repository makes API call with Bearer token
6. Response is parsed into list of `Opd` objects
7. State updates to `PrescriptionOpdListLoaded`
8. UI displays OPD cards

### Loading Prescription Details

1. User taps on an OPD card
2. Navigation to `PrescriptionDetailsPage` with `opdId`
3. Page sends `PrescriptionLoadDetails` event
4. Bloc validates token and makes API call
5. Response is parsed into list of `Prescription` objects
6. State updates to `PrescriptionDetailsLoaded`
7. UI displays OPD info and prescription list

## Error Handling

### Authentication Errors

- Token expiration automatically detected
- User shown "Authentication required. Please login again." message
- Logged with ❌ emoji prefix

### API Errors

- HTTP status code errors caught and logged
- User-friendly error messages displayed via Snackbar
- Full error details logged to console

### Network Errors

- Connection issues caught and logged
- Generic error message shown to user

## Debug Logging

All API operations include comprehensive logging:

- **🔵 Blue**: API calls (URL and parameters)
- **✅ Green**: Successful operations
- **❌ Red**: Errors
- **📋 Clipboard**: Loading operations
- **💊 Pill**: Prescription-specific operations

Example log output:

```
🔵 Fetching OPDs by booklet: http://10.17.1.5/api/Patients/my-opd-by-booklet/23323039
🔵 OPD by booklet response status: 200
🔵 OPD by booklet response body: [{"opdid":11024384,...}]
✅ Successfully fetched 2 OPDs
```

## Future Enhancements

### Potential Features to Implement:

1. **Download Functionality**

   - Single prescription PDF download
   - "Download All" for all prescriptions
   - Generate shareable prescription summary

2. **Search & Filter**

   - Search by doctor name, diagnosis, or date
   - Filter by date range
   - Sort by recent, doctor, etc.

3. **Offline Support**

   - Cache prescription data locally
   - Sync when online

4. **Additional Details**

   - Lab test results integration
   - Follow-up appointment scheduling
   - Medication reminders

5. **Print Support**
   - Print prescription from app
   - Format for printer-friendly layout

## Testing Checklist

- [x] OPD list loads with correct data
- [x] Prescription details load for selected OPD
- [x] Token expiration handled gracefully
- [x] Error messages display correctly
- [x] Loading states show appropriately
- [x] Empty states show when no data
- [x] Date formatting works correctly
- [x] Navigation between pages works
- [x] Back button preserves OPD list state
- [x] UI elements render correctly

## Schema References

Response schemas located at:

- `/schemas/api:Patientes:my-opd-by-booklet:{bookletNo}.json`
- `/schemas/api:Patients:my-prescriptions:{opdId}.json`

Note: There's a typo in the OPD schema filename ("Patientes" instead of "Patients").

## Summary

The prescription functionality is fully integrated with:

- ✅ Two-tier API system (OPD list → Prescription details)
- ✅ Bearer token authentication
- ✅ BLoC state management pattern
- ✅ Comprehensive error handling
- ✅ Debug logging throughout
- ✅ Clean UI with loading/error/empty states
- ✅ Date formatting for better UX
- ✅ Proper navigation flow

All code follows the existing project architecture and patterns.
