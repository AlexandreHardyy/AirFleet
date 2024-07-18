class RetrieveResponse {
  String type;
  List<Feature> features;
  String attribution;

  RetrieveResponse({
    required this.type,
    required this.features,
    required this.attribution,
  });

  factory RetrieveResponse.fromJson(Map<String, dynamic> json) =>
      RetrieveResponse(
        type: json['type'],
        features: List<Feature>.from(
            json['features'].map((x) => Feature.fromJson(x))),
        attribution: json['attribution'],
      );
}

class Feature {
  String type;
  Geometry geometry;
  Properties properties;

  Feature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json['type'],
        geometry: Geometry.fromJson(json['geometry']),
        properties: Properties.fromJson(json['properties']),
      );
}

class Geometry {
  List<double> coordinates;
  String type;

  Geometry({
    required this.coordinates,
    required this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        coordinates:
            List<double>.from(json['coordinates'].map((x) => x.toDouble())),
        type: json['type'],
      );
}

class Properties {
  String name;
  String mapboxId;
  String featureType;
  String? address;
  String? fullAddress;
  String? placeFormatted;
  Context? context;
  Coordinates coordinates;
  String? language;
  String? maki;
  List<String>? poiCategory;
  List<String>? poiCategoryIds;
  ExternalIds? externalIds;
  Metadata? metadata;
  String? operationalStatus;

  Properties({
    required this.name,
    required this.mapboxId,
    required this.featureType,
    this.address,
    this.fullAddress,
    this.placeFormatted,
    this.context,
    required this.coordinates,
    this.language,
    this.maki,
    this.poiCategory,
    this.poiCategoryIds,
    this.externalIds,
    this.metadata,
    this.operationalStatus,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        name: json['name'],
        mapboxId: json['mapbox_id'],
        featureType: json['feature_type'],
        address: json['address'],
        fullAddress: json['full_address'],
        placeFormatted: json['place_formatted'],
        context:
            json['context'] != null ? Context.fromJson(json['context']) : null,
        coordinates: Coordinates.fromJson(json['coordinates']),
        language: json['language'],
        maki: json['maki'],
        poiCategory: json['poi_category'] != null
            ? List<String>.from(json['poi_category'].map((x) => x))
            : null,
        poiCategoryIds: json['poi_category_ids'] != null
            ? List<String>.from(json['poi_category_ids'].map((x) => x))
            : null,
        externalIds: json['external_ids'] != null
            ? ExternalIds.fromJson(json['external_ids'])
            : null,
        metadata: json['metadata'] != null
            ? Metadata.fromJson(json['metadata'])
            : null,
        operationalStatus: json['operational_status'],
      );
}

class Context {
  Country? country;
  Postcode? postcode;
  Place? place;
  Neighborhood? neighborhood;
  Address? address;
  Street? street;

  Context({
    this.country,
    this.postcode,
    this.place,
    this.neighborhood,
    this.address,
    this.street,
  });

  factory Context.fromJson(Map<String, dynamic> json) => Context(
        country:
            json['country'] != null ? Country.fromJson(json['country']) : null,
        postcode: json['postcode'] != null
            ? Postcode.fromJson(json['postcode'])
            : null,
        place: json['place'] != null ? Place.fromJson(json['place']) : null,
        neighborhood: json['neighborhood'] != null
            ? Neighborhood.fromJson(json['neighborhood'])
            : null,
        address:
            json['address'] != null ? Address.fromJson(json['address']) : null,
        street: json['street'] != null ? Street.fromJson(json['street']) : null,
      );
}

class Country {
  String id;
  String name;
  String countryCode;
  String countryCodeAlpha3;

  Country({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.countryCodeAlpha3,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id'],
        name: json['name'],
        countryCode: json['country_code'],
        countryCodeAlpha3: json['country_code_alpha_3'],
      );
}

class Postcode {
  String id;
  String name;

  Postcode({
    required this.id,
    required this.name,
  });

  factory Postcode.fromJson(Map<String, dynamic> json) => Postcode(
        id: json['id'],
        name: json['name'],
      );
}

class Place {
  String id;
  String name;

  Place({
    required this.id,
    required this.name,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: json['id'],
        name: json['name'],
      );
}

class Neighborhood {
  String? id;
  String? name;

  Neighborhood({
    this.id,
    this.name,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) => Neighborhood(
        id: json['id'],
        name: json['name'],
      );
}

class Address {
  String id;
  String? name;
  String? addressNumber;
  String? streetName;

  Address({
    required this.id,
    this.name,
    this.addressNumber,
    this.streetName,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'],
        name: json['name'],
        addressNumber: json['address_number'],
        streetName: json['street_name'],
      );
}

class Street {
  String id;
  String name;

  Street({
    required this.id,
    required this.name,
  });

  factory Street.fromJson(Map<String, dynamic> json) => Street(
        id: json['id'],
        name: json['name'],
      );
}

class Coordinates {
  double latitude;
  double longitude;
  List<RoutablePoint>? routablePoints;

  Coordinates({
    required this.latitude,
    required this.longitude,
    this.routablePoints,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        latitude: json['latitude'],
        longitude: json['longitude'],
        routablePoints: json['routable_points'] != null
            ? List<RoutablePoint>.from(
                json['routable_points'].map((x) => RoutablePoint.fromJson(x)))
            : null,
      );
}

class RoutablePoint {
  String name;
  double latitude;
  double longitude;

  RoutablePoint({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory RoutablePoint.fromJson(Map<String, dynamic> json) => RoutablePoint(
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}

class ExternalIds {
  String? foursquare;

  ExternalIds({
    required this.foursquare,
  });

  factory ExternalIds.fromJson(Map<String, dynamic> json) => ExternalIds(
        foursquare: json['foursquare'],
      );
}

class Metadata {
  String? primaryPhoto;

  Metadata({
    this.primaryPhoto,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        primaryPhoto: json['primary_photo'],
      );
}
