import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? historyTitle;
  final String? historyValue;

  const StatsCard({
    super.key,
    this.historyTitle,
    this.historyValue,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = Colors.blue,
    this.bgColor = Colors.white,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  late bool isNegative;

  @override
  void initState() {
    super.initState();
    statsCheck();
  }

  Future<void> statsCheck() async {
    final currentValue = int.tryParse(widget.value) ?? 0;
    final previousValue = int.tryParse(widget.historyValue!) ?? 0;
    setState(() {
      isNegative = currentValue < previousValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust icon size and font size based on screen width
    final iconSize = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.04;
    final valueFontSize = screenWidth * 0.07;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01, // Adjust margin based on screen height
        horizontal: screenWidth * 0.03, // Adjust horizontal padding
      ),
      padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: widget.iconColor.withOpacity(0.2),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: iconSize,
            ), // Dynamic icon size
            radius: screenWidth * 0.1, // Adjust radius dynamically
          ),
          SizedBox(width: screenWidth * 0.04), // Adjust spacing dynamically
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize, // Dynamic title font size
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ), // Dynamic vertical spacing
                Text(
                  widget.value,
                  style: GoogleFonts.poppins(
                    fontSize: valueFontSize, // Dynamic value font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (widget.historyTitle != null && widget.historyValue != null)
                  Row(
                    children: [
                      Text(
                        widget.historyTitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(
                        width: screenHeight * 0.01,
                      ), // Dynamic vertical spacing
                      Text(
                        widget.historyValue!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (widget.historyValue == '0' &&
                              widget.value == '0') {
                            return Icon(
                              Icons.align_vertical_center_rounded,
                              color: Colors.grey,
                            );
                          } else {
                            return Icon(
                              isNegative
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isNegative ? Colors.red : Colors.green,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
