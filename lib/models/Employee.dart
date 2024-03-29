class Employee {
  String _name;
  String _aadhar;
  String _DOJ;
  String _phone;
  String _wage;
  String _allowance;
  String _overTime;
  String _advance;
  String _gender;
  bool _isPF;
  bool _isESI;
  //bool _checked;


  Employee(this._name, this._aadhar, this._DOJ, this._phone, this._allowance,
   this._wage,this._overTime,this._advance,this._gender,this._isPF,this._isESI);




  String get name => _name;

  String get aadhar => _aadhar;
  String get gender => _gender;
  bool get isESI => _isESI;

  String get DOJ => _DOJ;

  String get phone => _phone;

  String get allowance => _allowance;

  String get overTime => _overTime;
  String get advance => _advance;


 // bool get checked => _checked;

  String get wage => _wage;
  bool get isPF => _isPF;

  set name(String d) {
    this._name = d;
  }

  set aadhar(String d) {
    this._aadhar = d;
  }

  set gender(String d) {
    this._gender = d;
  }
  set isESI(bool d) {
    this._isESI = d;
  }


  set phone(String d) {
    this._phone = d;
  }


  set allowance(String x) {
    this._allowance = x;
  }



  set overTime(String x) {
    this._overTime = x;
  }
  set wage(String x) {
    this._wage = x;
  }

  set isPF(bool x) {
    this._isPF = x;
  }
  set advance(String x) {
    this._advance = x;
  }


  //set checked(bool x) {this._checked = x;}


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

    map['gender'] = _gender;
    map['isPF'] = _isPF;
    map['isESI'] = _isESI;




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
   // this._checked=false;


    this._gender = map['gender'];
    this._isPF = map['isPF'];
    this._isESI = map['isESI'];
  }
}
