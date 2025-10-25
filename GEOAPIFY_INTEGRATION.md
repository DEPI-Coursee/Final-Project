# Geoapify API Integration

This project integrates the Geoapify Places API using GetX for state management and Dio for HTTP requests. The places are displayed directly on the home screen.

## Files Created/Modified

### 1. **Model** (`lib/models/place_model.dart`)
- Represents a place with the following properties:
  - `name`: Place name
  - `addressLine2`: Address line 2 from the API
  - `longitude`: Longitude coordinate
  - `latitude`: Latitude coordinate
  - `wikipediaUrl`: Wikipedia URL (if available)
  - `wikidataId`: Wikidata ID (if available)
  - `country`: Country name
  - `category`: Place category

### 2. **Service** (`lib/services/places_service.dart`)
- Handles API communication with Geoapify
- Method: `getPlaces()` with configurable parameters:
  - `categories`: Type of places (default: "tourism.attraction")
  - `longitude`: Center longitude
  - `latitude`: Center latitude
  - `radius`: Search radius in meters
  - `limit`: Maximum number of results

### 3. **Home Screen** (`lib/screens/home_screen.dart`)
- Integrated Geoapify API directly into the home screen
- Features:
  - Displays places from the API in a scrollable list
  - Loading state with progress indicator
  - Error handling with retry button
  - Empty state with "Load Places" button
  - All API logic is self-contained (no separate controller)

## How It Works

The home screen has built-in API integration with:
- **Observable variables** using GetX:
  - `places`: RxList of PlaceModel
  - `isLoading`: RxBool for loading state
  - `errorMessage`: RxString for error messages

- **API parameters** (all configurable):
  - categories: "tourism.attraction"
  - longitude: 31.2357 (Giza, Egypt)
  - latitude: 30.0444 (Giza, Egypt)
  - radius: 10000 meters
  - limit: 20 results

- **Method**: `fetchPlaces()` - Fetches places from the API

## Usage

When the app loads, the home screen will show an empty state with a "Load Places" button. Click the button to fetch places from the Geoapify API.

The places will be displayed with:
- Place name
- Address line 2 (if available)
- Country
- Category
- Visual icon placeholder

## API Configuration

To change the search location or parameters, modify the variables in `HomeScreen`:

```dart
final categories = 'tourism.attraction';
final longitude = 31.2357;
final latitude = 30.0444;
final radius = 10000.0;
final limit = 20;
```

## Notes

- The API key is currently stored in the `PlacesService` class
- For production, move the API key to environment variables
- The code is kept simple without a separate controller
- All state management is handled with GetX observables
- Error handling and loading states are fully implemented
