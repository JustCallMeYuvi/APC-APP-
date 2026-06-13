
import 'package:animated_movies_app/car_kms_module/car_booking_model.dart';
import 'package:flutter/material.dart';


class CarBookingCard extends StatelessWidget {
  final CarBookingTrack booking;
  final String formattedTime;
  final VoidCallback onSave;

  const CarBookingCard({
    super.key,
    required this.booking,
    required this.formattedTime,
    required this.onSave,
  });

  Widget _row(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5C6178),
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInnova = booking.carName.toUpperCase().contains('INNOVA');
    final accent =
        isInnova ? const Color(0xFF8E6FF7) : const Color(0xFF22B8CF);
    final hasKms = booking.kmsCtrl.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1A1F36).withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.18),
                      accent.withOpacity(0.08)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isInnova
                      ? Icons.airport_shuttle_rounded
                      : Icons.directions_car_filled_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.carName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1E2139))),
                    const SizedBox(height: 1),
                    Text(booking.carNo,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9AA0BD),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasKms
                      ? const Color(0xFF16A34A).withOpacity(0.1)
                      : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        hasKms
                            ? Icons.check_circle_rounded
                            : Icons.tag_rounded,
                        size: 12,
                        color: hasKms
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF9AA0BD)),
                    const SizedBox(width: 4),
                    Text(
                      hasKms ? 'Done' : '#${booking.sno}',
                      style: TextStyle(
                          fontSize: 11,
                          color: hasKms
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF9AA0BD),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _row(Icons.person_rounded, booking.travellers,
              const Color(0xFF9AA0BD)),
          const SizedBox(height: 6),
          _row(Icons.access_time_filled_rounded, formattedTime,
              const Color(0xFF9AA0BD)),
          const Spacer(),

          // ── KM input + save ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: booking.kmsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2139)),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.speed_rounded,
                        size: 18, color: Color(0xFF5B5FEF)),
                    hintText: 'Actual KMs',
                    hintStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FB),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF5B5FEF), width: 1.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                width: 46,
                child: ElevatedButton(
                  onPressed: booking.saving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B5FEF),
                    disabledBackgroundColor:
                        const Color(0xFF5B5FEF).withOpacity(0.6),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: booking.saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_rounded,
                          color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}