import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'number_picker.dart';

class LinearDatePicker extends StatefulWidget {
  final bool showDay;
  final Function(String date) dateChangeListener;

  final String startDate;
  final String endDate;
  final String initialDate;

  final TextStyle? labelStyle;
  final TextStyle? selectedRowStyle;
  final TextStyle? unselectedRowStyle;

  final String yearText;
  final String monthText;
  final String dayText;

  final bool showLabels;
  final double columnWidth;
  final bool showMonthName;
  final String? languageCode;

  LinearDatePicker({
    this.startDate = "",
    this.endDate = "",
    this.initialDate = "",
    required this.dateChangeListener,
    this.showDay = true,
    this.labelStyle,
    this.selectedRowStyle,
    this.unselectedRowStyle,
    this.yearText = "سال",
    this.monthText = "ماه",
    this.dayText = "روز",
    this.showLabels = true,
    this.columnWidth = 55.0,
    this.showMonthName = false,
    this.languageCode = 'en',
  });

  @override
  _LinearDatePickerState createState() => _LinearDatePickerState();
}

class _LinearDatePickerState extends State<LinearDatePicker> {
  int? _selectedYear;
  int? _selectedMonth;
  late int _selectedDay;

  int? minYear;
  int? maxYear;

  int minMonth = 01;
  int maxMonth = 12;

  int minDay = 01;
  int maxDay = 31;

  @override
  initState() {
    super.initState();
    minYear = Gregorian.now().year - 100;
    maxYear = Gregorian.now().year;
    if (widget.initialDate.isNotEmpty) {
      List<String> initList = widget.initialDate.split("/");
      _selectedYear = int.parse(initList[0]);
      _selectedMonth = int.parse(initList[1]);
      if (widget.showDay)
        _selectedDay = int.parse(initList[2]);
      else
        _selectedDay = Gregorian.now().day;
    } else {
      _selectedYear = Gregorian.now().year;
      _selectedMonth = Gregorian.now().month;
      _selectedDay = Gregorian.now().day;
    }
  }

  @override
  Widget build(BuildContext context) {
    maxDay = _getMonthLength(_selectedYear, _selectedMonth);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: widget.showLabels,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: widget.columnWidth,
                  child: Text(
                    widget.yearText,
                    style: widget.labelStyle,
                    textAlign: TextAlign.center,
                  )),
              SizedBox(
                  width: widget.columnWidth,
                  child: Text(
                    widget.monthText,
                    style: widget.labelStyle,
                    textAlign: TextAlign.center,
                  )),
              Visibility(
                visible: widget.showDay,
                child: SizedBox(
                    width: widget.columnWidth,
                    child: Text(
                      widget.dayText,
                      style: widget.labelStyle,
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker.integer(
                listViewWidth: widget.columnWidth,
                initialValue: _selectedYear!,
                minValue: _getMinimumYear()!,
                maxValue: _getMaximumYear(),
                selectedRowStyle: widget.selectedRowStyle,
                unselectedRowStyle: widget.unselectedRowStyle,
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value as int?;
                    if (widget.showDay)
                      widget.dateChangeListener("$_selectedYear/$_selectedMonth/$_selectedDay");
                    else
                      widget.dateChangeListener("$_selectedYear/$_selectedMonth");
                  });
                }),
            NumberPicker.integer(
                listViewWidth: widget.columnWidth,
                initialValue: _selectedMonth!,
                minValue: _getMinimumMonth(),
                maxValue: _getMaximumMonth(),
                selectedRowStyle: widget.selectedRowStyle,
                unselectedRowStyle: widget.unselectedRowStyle,
                isShowMonthName: widget.showMonthName,
                languageCode: widget.languageCode,
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value as int?;
                    if (widget.showDay)
                      widget.dateChangeListener("$_selectedYear/$_selectedMonth/$_selectedDay");
                    else
                      widget.dateChangeListener("$_selectedYear/$_selectedMonth");
                  });
                }),
            Visibility(
              visible: widget.showDay,
              child: NumberPicker.integer(
                  listViewWidth: widget.columnWidth,
                  initialValue: _selectedDay,
                  minValue: _getMinimumDay(),
                  maxValue: _getMaximumDay(),
                  selectedRowStyle: widget.selectedRowStyle,
                  unselectedRowStyle: widget.unselectedRowStyle,
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value as int;
                      if (widget.showDay)
                        widget.dateChangeListener("$_selectedYear/$_selectedMonth/$_selectedDay");
                      else
                        widget.dateChangeListener("$_selectedYear/$_selectedMonth");
                    });
                  }),
            )
          ],
        ),
      ],
    );
  }

  _getMonthLength(int? selectedYear, int? selectedMonth) {
    DateTime firstOfNextMonth;
    if (selectedMonth == 12) {
      firstOfNextMonth = DateTime(selectedYear! + 1, 1, 1, 12); //year, selectedMonth, day, hour
    } else {
      firstOfNextMonth = DateTime(selectedYear!, selectedMonth! + 1, 1, 12);
    }
    int numberOfDaysInMonth = firstOfNextMonth.subtract(Duration(days: 1)).day;
    //.subtract(Duration) returns a DateTime, .day gets the integer for the day of that DateTime
    return numberOfDaysInMonth;
  }

  int _getMinimumMonth() {
    if (widget.startDate.isNotEmpty) {
      var startList = widget.startDate.split("/");
      int startMonth = int.parse(startList[1]);

      if (_selectedYear == _getMinimumYear()) {
        return startMonth;
      }
    }

    return minMonth;
  }

  int _getMaximumMonth() {
    if (widget.endDate.isNotEmpty) {
      var endList = widget.endDate.split("/");
      int endMonth = int.parse(endList[1]);
      if (_selectedYear == _getMaximumYear()) {
        return endMonth;
      }
    }
    return maxMonth;
  }

  int? _getMinimumYear() {
    if (widget.startDate.isNotEmpty) {
      var startList = widget.startDate.split("/");
      return int.parse(startList[0]);
    }
    return minYear;
  }

  _getMaximumYear() {
    if (widget.endDate.isNotEmpty) {
      var endList = widget.endDate.split("/");
      return int.parse(endList[0]);
    }
    return maxYear;
  }

  int _getMinimumDay() {
    if (widget.startDate.isNotEmpty && widget.showDay) {
      var startList = widget.startDate.split("/");
      int startDay = int.parse(startList[2]);

      if (_selectedYear == _getMinimumYear() && _selectedMonth == _getMinimumMonth()) {
        return startDay;
      }
    }

    return minDay;
  }

  int _getMaximumDay() {
    if (widget.endDate.isNotEmpty && widget.showDay) {
      var endList = widget.endDate.split("/");
      int endDay = int.parse(endList[2]);
      if (_selectedYear == _getMaximumYear() && _selectedMonth == _getMaximumMonth()) {
        return endDay;
      }
    }
    return _getMonthLength(_selectedYear, _selectedMonth);
  }
}
