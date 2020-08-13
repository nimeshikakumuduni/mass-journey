class TripData {
  int tripId, vehicleId;
  String purpose, dateTime, empId, mApproveDateTime, mEmpId, tMEmpId, dEmpId, firstName, lastName, imageUrl, tel, dFullName, vehicleNumber;
  bool isConfirm, isDeleted, isMApprove, isDone, isStarted;
  double pickLong, pickLati, destiLong, destiLati;
  TripData(data) {
    this.tripId = int.parse(data['tripId'].toString());
    this.vehicleId = data['vehicleId'];
    this.purpose = data['purpose'];
    this.dateTime = data['dateTime'];
    this.pickLong = data['pickLong'];
    this.pickLati = data['pickLati'];
    this.destiLong = data['destiLong'];
    this.destiLati = data['destiLati'];
    this.firstName = data['firstName'];
    this.lastName = data['lastName'];
    this.imageUrl = data['imageUrl'];
    this.empId = data['empId'];
    this.tel = data['tel'];
    this.mApproveDateTime = data['mApproveDateTime'];
    this.mEmpId = data['mEmpId'];
    this.tMEmpId = data['tMEmpId'];
    this.dEmpId = data['dEmpId'];
    this.isConfirm = data['isConfirm'] == 1 ? true : false;
    this.isDeleted = data['isDeleted'] == 1 ? true : false;
    this.isMApprove = data['isMApprove'] == 1 ? true : false;
    this.isStarted = data['isStarted'] == 1 ? true : false;
    this.isDone = data['isDone'] == 1 ? true : false;
    this.vehicleNumber = data['vehicleNumber'];
  }
}
