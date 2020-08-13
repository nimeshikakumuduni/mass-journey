class User {
  static Map<String, dynamic> dummyData = {
    'firstName': 'Sahan',
    'lastName': 'Pasindu',
    'userName': 'sahanperera',
    'empId': '12345',
    'password': 'sahan1997',
    'nic': '971802170v',
    'tel': '0702129472',
    'isAdmin': true,
    'isOnline': false,
    'isRegistered': true,
    'isDeleted': false,
    'position': 'Manager',
    'imageUrl': ''
  };

  static User currentUser;
  static String defaultProfPict = 'assets/defaultProfilePicture.jpg';

  String firstName;
  String lastName;
  String userName;
  String empId;
  String password;
  String nic;
  String position;
  String tel;
  String imageUrl;
  bool isAdmin;
  bool isOnline;
  bool isRegistered;
  bool isDeleted;

  User(var data) {
    this.firstName = data['firstName'];
    this.lastName = data['lastName'];
    this.userName = data['userName'];
    this.empId = data['empId'];
    this.password = data['password'];
    this.nic = data['nic'];
    this.isAdmin = data['isAdmin'] == 0 ? false : true;
    this.isOnline = data['isOnline'] == 0 ? false : true;
    this.isRegistered = data['isRegistered'] == 0 ? false : true;
    this.position = data['position'];
    this.tel = data['tel'];
    this.isDeleted = data['isDeleted'] == 0 ? false : true;
    this.imageUrl = data['imageUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'empId': empId,
      'password': password,
      'nic': nic,
      'isAdmin': isAdmin,
      'isOnline': isOnline,
      'isRegistered': isRegistered,
      'position': position,
      'tel': tel,
      'isDeleted': isDeleted,
      'imageUrl': imageUrl
    };
  }
}

class MinUser {
  String firstName, lastName, fullName, empId, imageUrl, tel;
  bool isAdmin;
  MinUser(data) {
    this.firstName = data['firstName'];
    this.lastName = data['lastName'];
    this.fullName = this.firstName + ' ' + this.lastName;
    this.empId = data['empId'];
    this.imageUrl = data['imageUrl'];
    this.tel = data['tel'];
    this.isAdmin = data['isAdmin'] == 0 ? false : true;
  }
}
