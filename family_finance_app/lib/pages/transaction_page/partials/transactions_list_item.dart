import 'package:family_financial_app/models/responses/item_transaction.dart';
import 'package:family_financial_app/plugins/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsListItem extends StatelessWidget {
  final ItemTransaction transaction;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionsListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        shadowColor: Colors.grey.withValues(alpha: .25),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap ?? () {},
          onLongPress: onLongPress ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              verticalDirection: VerticalDirection.up,
              children: [
                Row(
                  children: [
                    Container(
                      // Category Icon
                      decoration: BoxDecoration(
                        color: Utils.hexStringToColor(
                          transaction.categoryColor,
                        ).withAlpha(60),
                        borderRadius: BorderRadius.lerp(
                          BorderRadius.circular(8.0),
                          BorderRadius.circular(24.0),
                          .5,
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        IconData(
                          transaction.categoryIcon,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Utils.hexStringToColor(
                          transaction.categoryColor,
                        ).withAlpha(95),
                        size: 40,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Description
                          transaction.description,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        transaction.notes == null
                            ? const SizedBox()
                            : Container(
                                padding: const EdgeInsets.only(right: 8.0),
                                width: MediaQuery.of(context).size.width * 0.36,
                                child: Wrap(
                                  textDirection: TextDirection.ltr,
                                  children: [
                                    Text(
                                      transaction.notes!,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.interTight(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 3.0),
                        Row(
                          // Account
                          children: [
                            Icon(
                              Icons.circle,
                              color: Utils.hexStringToColor(
                                transaction.accountColor,
                              ),
                              size: 14,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              transaction.account,
                              style: GoogleFonts.interTight(fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          transaction.category,
                          style: GoogleFonts.interTight(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (transaction.transactionType == 1 ? '' : '- ') +
                          Utils.formatCurrency(transaction.amount),
                      style: GoogleFonts.interTight(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: transaction.transactionType == 1
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      transaction.transactionDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                    Text(
                      transaction.transactionTime,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
