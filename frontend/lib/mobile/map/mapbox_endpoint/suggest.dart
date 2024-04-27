class SuggestionResponse {
  List<Suggestion> suggestions;
  String attribution;

  SuggestionResponse({required this.suggestions, required this.attribution});

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) {
    return SuggestionResponse(
      suggestions: (json['suggestions'] as List).map((i) => Suggestion.fromJson(i)).toList(),
      attribution: json['attribution']
    );
  }
}

class Suggestion {
  String name;
  String? namePreferred;
  String mapboxId;
  String featureType;
  String? address;
  String? fullAddress;
  String? placeFormatted;
  Context context;
  String language;
  String maki;
  List<String>? poiCategory;
  List<String>? poiCategoryIds;
  Map<String, dynamic>? externalIds;
  Map<String, dynamic>? metadata;
  String? operationalStatus;
  List<String>? brand;

  Suggestion({
    required this.name,
    this.namePreferred,
    required this.mapboxId,
    required this.featureType,
    this.address,
    this.fullAddress,
    this.placeFormatted,
    required this.context,
    required this.language,
    required this.maki,
    this.poiCategory,
    this.poiCategoryIds,
    this.externalIds,
    this.metadata,
    this.operationalStatus,
    this.brand,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      name: json['name'],
      namePreferred: json['name_preferred'],
      mapboxId: json['mapbox_id'],
      featureType: json['feature_type'],
      address: json['address'],
      fullAddress: json['full_address'],
      placeFormatted: json['place_formatted'],
      context: Context.fromJson(json['context']),
      language: json['language'],
      maki: json['maki'],
      poiCategory: json['poi_category'] != null ? List<String>.from(json['poi_category']) : null,
      poiCategoryIds: json['poi_category_ids'] != null ? List<String>.from(json['poi_category_ids']) : null,
      externalIds: json['external_ids'],
      metadata: json['metadata'],
      operationalStatus: json['operational_status'],
      brand: json['brand'] != null ? List<String>.from(json['brand']) : null,
    );
  }
}

class Context {
  Country? country;
  Postcode? postcode;
  Place? place;
  Neighborhood? neighborhood;
  Address? address;
  Street? street;
  Region? region;
  District? district;

  Context({
    this.country,
    this.postcode,
    this.place,
    this.neighborhood,
    this.address,
    this.street,
    this.region,
    this.district,
  });

  factory Context.fromJson(Map<String, dynamic> json) {
    return Context(
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      postcode: json['postcode'] != null ? Postcode.fromJson(json['postcode']) : null,
      place: json['place'] != null ? Place.fromJson(json['place']) : null,
      neighborhood: json['neighborhood'] != null ? Neighborhood.fromJson(json['neighborhood']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      street: json['street'] != null ? Street.fromJson(json['street']) : null,
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
      district: json['district'] != null ? District.fromJson(json['district']) : null,
    );
  }
}

class Country {
  String? name;
  String? countryCode;
  String? countryCodeAlpha3;

  Country({this.name, this.countryCode, this.countryCodeAlpha3});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      countryCode: json['country_code'],
      countryCodeAlpha3: json['country_code_alpha_3'],
    );
  }
}

class Postcode {
  String? id;
  String? name;

  Postcode({this.id, this.name});

  factory Postcode.fromJson(Map<String, dynamic> json) {
    return Postcode(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Place {
  String? id;
  String? name;

  Place({this.id, this.name});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Neighborhood {
  String? id;
  String? name;

  Neighborhood({this.id, this.name});

  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Address {
  String? name;
  String? addressNumber;
  String? streetName;

  Address({this.name, this.addressNumber, this.streetName});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'],
      addressNumber: json['address_number'],
      streetName: json['street_name'],
    );
  }
}

class Street {
  String? name;

  Street({this.name});

  factory Street.fromJson(Map<String, dynamic> json) {
    return Street(
      name: json['name'],
    );
  }
}

class Region {
  String? id;
  String? name;
  String? regionCode;
  String? regionCodeFull;

  Region({this.id, this.name, this.regionCode, this.regionCodeFull});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      regionCode: json['region_code'],
      regionCodeFull: json['region_code_full'],
    );
  }
}

class District {
  String? id;
  String? name;

  District({this.id, this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
    );
  }
}