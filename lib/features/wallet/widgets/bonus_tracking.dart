import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/features/wallet/models/bonus_tracking_models.dart';

import 'daily_bonus_tracker.dart';
import 'monthly_top_performer_card.dart';
import 'weekly_performance_card.dart';

class BonusTracking extends StatelessWidget {
  const BonusTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DailyBonusTracker(
          deliveriesToday: 8,
          targetDeliveries: 10,
          nextBonus: '₹80',
          remainingDeliveries: 2,
          streakMessage: '5-Day Bonus Streak! Keep going to maintain your streak',
          motivationalMessage: 'Just 2 more deliveries!',
          bonusesEarned: const [
            BonusMilestone(
              title: 'Breakfast Rush Bonus',
              description: 'Complete 5 deliveries before 10 AM',
              isCompleted: true,
            ),
            BonusMilestone(
              title: 'Lunch Peak Bonus',
              description: 'Finish 8 deliveries by 3 PM',
              isCompleted: true,
            ),
            BonusMilestone(
              title: 'Dinner Rush Bonus',
              description: 'Finish 12 deliveries by 9 PM',
              isCompleted: false,
            ),
          ],
          tierProgress: const [
            BonusTierProgress(
              label: 'Tier 1 • ₹40',
              current: 8,
              target: 10,
            ),
            BonusTierProgress(
              label: 'Tier 2 • ₹80',
              current: 8,
              target: 15,
            ),
            BonusTierProgress(
              label: 'Tier 3 • ₹120',
              current: 8,
              target: 20,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        WeeklyPerformanceCard(
          currentRating: 4.6,
          targetRating: 4.5,
          weeklyBonus: '₹400',
          isEligible: true,
        ),
        SizedBox(height: 12.h),
        MonthlyTopPerformerCard(
          currentRank: 3,
          totalDeliveries: 287,
          totalParticipants: 47,
          prize: '₹250',
          score: 485,
          payoutDate: 'Paid on 1st of next month',
          scoreBreakdown: const [
            ScoreBreakdown(
              title: 'Deliveries',
              formula: '287 × 0.5',
              points: '143 pts',
            ),
            ScoreBreakdown(
              title: 'Rating',
              formula: '4.8 × 50',
              points: '240 pts',
            ),
            ScoreBreakdown(
              title: 'On-Time',
              formula: '98% × 2',
              points: '196 pts',
            ),
          ],
          prizeTiers: const [
            PrizeTier(rankLabel: 'Rank 1', reward: '₹2,000'),
            PrizeTier(rankLabel: 'Rank 2', reward: '₹1,000'),
            PrizeTier(rankLabel: 'Rank 3', reward: '₹500'),
            PrizeTier(rankLabel: 'Top 10', reward: '₹250'),
          ],
          onViewLeaderboard: null,
        ),
      ],
    );
  }
}
