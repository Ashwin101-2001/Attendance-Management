class Employee {
  String _name;
  String _aadhar;
  String _DOJ;
  String _phone;
  int _wage;
  int _allowance;
  int _attendance;
  int _overTimeHours;
  int _overTime;
  int _advance;


  Employee(this._name, this._aadhar, this._DOJ, this._phone, this._allowance,
   this._wage,this._overTime,this._advance);



  String get name => _name;

  String get aadhar => _aadhar;

  String get DOJ => _DOJ;

  String get phone => _phone;

  int get allowance => _allowance;

  int get attendance => _attendance;

  int get overTimeHours => _overTimeHours;
  int get overTime => _overTime;
  int get advance => _advance;

  int get wage => _wage;

  set name(String d) {
    this._name = d;
  }

  set aadhar(String d) {
    this._aadhar = d;
  }

  set phone(String d) {
    this._phone = d;
  }

  set attendance(int x) {
    this._attendance = x;
  }

  set allowance(int x) {
    this._allowance = x;
  }

  set overTimeHours(int x) {
    this._overTimeHours = x;
  }

  set overTime(int x) {
    this._overTime = x;
  }
  set wage(int x) {
    this._wage = x;
  }
  set advance(int x) {
    this._advance = x;
  }


  Map<String, dynamic> get map {
    var map = Map<String, dynamic>();

    map['name'] = _name;
    map['aadhar'] = _aadhar;
    map['phone'] = _phone;
    map['DOJ'] = _DOJ;
    map['wage'] = _wage;
    map['allowance'] = _allowance;
    map['overTime'] = _overTime;
    map['advance'] = _advance;



    return map;
  }


  Employee.fromMapObject(Map<String, dynamic> map) {

    this._aadhar = map['aadhar'];
    this._phone = map['phone'];
    this._name = map['name'];
    this._DOJ = map['DOJ'];
    this._wage = map['wage'];
    this._allowance = map['allowance'];
    this._overTime = map['overTime'];
    this._advance = map['advance'];

  }
}
