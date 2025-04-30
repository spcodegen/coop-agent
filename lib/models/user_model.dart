import 'dart:convert';

class UserModel {
  final int id;
  final String username;
  final List<Role> roles;
  final String createdBy;
  final String createdDateTime;
  final String modifiedBy;
  final String modifiedDateTime;
  final String isDeleted;
  final String status;
  final String coopCityUser; // NEW FIELD
  final SalesPersonDetails salesPersonDetails;

  UserModel({
    required this.id,
    required this.username,
    required this.roles,
    required this.createdBy,
    required this.createdDateTime,
    required this.modifiedBy,
    required this.modifiedDateTime,
    required this.isDeleted,
    required this.status,
    required this.coopCityUser, // NEW FIELD
    required this.salesPersonDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      roles:
          (json['roles'] as List).map((role) => Role.fromJson(role)).toList(),
      createdBy: json['createdBy'],
      createdDateTime: json['createdDateTime'],
      modifiedBy: json['modifiedBy'],
      modifiedDateTime: json['modifiedDateTime'],
      isDeleted: json['isDeleted'],
      status: json['status'],
      coopCityUser: json['coopCityUser'], // NEW FIELD
      salesPersonDetails:
          SalesPersonDetails.fromJson(json['salesPersonDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "roles": roles.map((role) => role.toJson()).toList(),
      "createdBy": createdBy,
      "createdDateTime": createdDateTime,
      "modifiedBy": modifiedBy,
      "modifiedDateTime": modifiedDateTime,
      "isDeleted": isDeleted,
      "status": status,
      "coopCityUser": coopCityUser, // NEW FIELD
      "salesPersonDetails": salesPersonDetails.toJson(),
    };
  }
}

class Role {
  final int id;
  final String name;
  final String status;

  Role({required this.id, required this.name, required this.status});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "status": status};
  }
}

class SalesPersonDetails {
  final int id;
  final String sfcCode;
  final String fullName;
  final String sfcBranchCode;
  final String slcBranchDescription;
  final int sfcLevel;
  final String? division;
  final String? coopSociety; // NEW FIELD
  final String? coopCity; // NEW FIELD
  final String createdBy;
  final String createdDateTime;
  final String modifiedBy;
  final String modifiedDateTime;
  final String isDeleted;
  final String status;

  SalesPersonDetails({
    required this.id,
    required this.sfcCode,
    required this.fullName,
    required this.sfcBranchCode,
    required this.slcBranchDescription,
    required this.sfcLevel,
    required this.division,
    required this.coopSociety, // NEW FIELD
    required this.coopCity, // NEW FIELD
    required this.createdBy,
    required this.createdDateTime,
    required this.modifiedBy,
    required this.modifiedDateTime,
    required this.isDeleted,
    required this.status,
  });

  factory SalesPersonDetails.fromJson(Map<String, dynamic> json) {
    return SalesPersonDetails(
      id: json['id'],
      sfcCode: json['sfcCode'],
      fullName: json['fullName'],
      sfcBranchCode: json['sfcBranchCode'],
      slcBranchDescription: json['slcBranchDescription'],
      sfcLevel: json['sfcLevel'],
      division: json['division'],
      coopSociety: json['coopSociety'], // NEW FIELD
      coopCity: json['coopCity'], // NEW FIELD
      createdBy: json['createdBy'],
      createdDateTime: json['createdDateTime'],
      modifiedBy: json['modifiedBy'],
      modifiedDateTime: json['modifiedDateTime'],
      isDeleted: json['isDeleted'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sfcCode": sfcCode,
      "fullName": fullName,
      "sfcBranchCode": sfcBranchCode,
      "slcBranchDescription": slcBranchDescription,
      "sfcLevel": sfcLevel,
      "division": division,
      "coopSociety": coopSociety, // NEW FIELD
      "coopCity": coopCity, // NEW FIELD
      "createdBy": createdBy,
      "createdDateTime": createdDateTime,
      "modifiedBy": modifiedBy,
      "modifiedDateTime": modifiedDateTime,
      "isDeleted": isDeleted,
      "status": status,
    };
  }
}
