import 'package:intl/intl.dart';
import 'Utils/DBHelper.dart';
import 'Utils/transaction.dart';
import 'package:personal_finance_management_app/events/add_transactions.dart';
import 'package:personal_finance_management_app/events/update_transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/transaction_bloc.dart';

class TransactionForm extends StatefulWidget {
  final OTransaction transaction;
  final int transactionIndex;

  TransactionForm({this.transaction, this.transactionIndex});

  @override
  State<StatefulWidget> createState() {
    return TransactionFormState();
  }
}

class TransactionFormState extends State<TransactionForm> {
  String _name;
  int _amount;
  var datecontroller = TextEditingController();
  final List<String> items = <String>[
    'Category',
    'Food',
    'Clothing',
    'Daily Needs',
    'Miscellaneous'
  ];
  String selectedItem = 'Category';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _dateTime = DateTime.now();
  var date;

  _transactionDate(BuildContext context) async {
    var pickdate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: _dateTime);

    if (pickdate != null) {
      setState(() {
        date = pickdate;

        datecontroller.text = DateFormat('dd-MM-yyyy').format(date);
      });
    }
  }

  Widget _buildName() {
    return TextFormField(
      initialValue: _name,
      decoration: InputDecoration(
        labelText: 'Name',
        suffixIcon: InkWell(
          child: Icon(Icons.person),
        ),
      ),
      //maxLength: 15,
      style: TextStyle(fontSize: 28),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _name = value;
      },
    );
  }

  Widget _buildAmount() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Amount',
        suffixIcon: InkWell(
          child: Icon(Icons.attach_money,
          ),
        ),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 28),
      validator: (String value) {
        int calories = int.tryParse(value);

        if (calories == null || calories == 0) {
          return 'Amount must be greater than 0';
        }

        return null;
      },
      onSaved: (String value) {
        _amount = int.parse(value);
      },
    );
  }

  Widget _builddate(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: datecontroller,
      decoration: InputDecoration(
          labelText: 'Date',
          suffixIcon: InkWell(
            onTap: () {
              _transactionDate(context);
              print(_dateTime);
            },
            child: Icon(Icons.calendar_today),
          )),
      style: TextStyle(fontSize: 28),
      validator: (String value) {
        return null;
      },
    );
  }

  Widget _buildcategories(BuildContext context) {
    return Container(
      width: 370,
      padding: const EdgeInsets.symmetric(vertical: 23.0, horizontal: 0.0),
      child: DropdownButton<String>(
        icon: Icon(
          Icons.arrow_drop_down,
          size: 30,
          color: Colors.black.withOpacity(0.55),
        ),
        //underline: Container(color:),
        //iconSize: 25,
        isExpanded: true,
        underline: Container(color:Colors.black.withOpacity(0.55), height:1.0),
        value: selectedItem,
        onChanged: (String string) => setState(() => selectedItem = string),
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((String item) {
            return Text(
              item,
              style: TextStyle(
                fontSize: 28,
                color: Colors.black.withOpacity(0.55),
              ),
              textAlign: TextAlign.justify,
            );
          }).toList();
        },
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            child: Text('$item', style: TextStyle(fontSize: 20)),
            value: item,
          );
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _name = widget.transaction.name;
      _amount = widget.transaction.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaction Form")),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildName(),
              _buildAmount(),
              _builddate(context),
              _buildcategories(context),
              SizedBox(height: 16),
              SizedBox(height: 20),
              widget.transaction == null
                  ? RaisedButton(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 140.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }

                        _formKey.currentState.save();

                        OTransaction trans = OTransaction(
                            name: _name,
                            amount: _amount,
                            date: datecontroller.text);

                        DatabaseProvider.db.insert(trans).then(
                              (storedtransaction) =>
                                  BlocProvider.of<TransactionBloc>(context).add(
                                Addtransaction(storedtransaction),
                              ),
                            );

                        Navigator.pop(context);
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text(
                            "Update",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              print("form");
                              return;
                            }

                            _formKey.currentState.save();

                            OTransaction transaction = OTransaction(
                              name: _name,
                              amount: _amount,
                            );

                            DatabaseProvider.db.update(widget.transaction).then(
                                  (storedtransaction) =>
                                      BlocProvider.of<TransactionBloc>(context)
                                          .add(
                                    Updatetransaction(
                                        widget.transactionIndex, transaction),
                                  ),
                                );

                            Navigator.pop(context);
                          },
                        ),
                        RaisedButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
