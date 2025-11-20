import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/features/wallet/models/bonus_tracking_models.dart';
import 'package:quikle_rider/features/wallet/models/leaderboard_standing.dart';
import 'package:quikle_rider/features/wallet/models/rider_performance.dart';

import 'daily_bonus_tracker.dart';
import 'monthly_top_performer_card.dart';
import 'weekly_performance_card.dart';

class BonusTracking extends StatelessWidget {
  const BonusTracking({
    super.key,
    this.performance,
    this.leaderboard,
  });

  final RiderPerformance? performance;
  final LeaderboardStanding? leaderboard;

  @override
  Widget build(BuildContext context) {
    final performanceData = performance;
    final leaderboardData = leaderboard;

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
          acceptanceRate: performanceData?.acceptanceRate ?? '--',
          onTimeRate: performanceData?.onTimeRate ?? '--',
          totalDeliveries: performanceData?.totalDeliveries ?? 0,
        ),
        SizedBox(height: 12.h),
        MonthlyTopPerformerCard(
          currentRank: leaderboardData?.rank,
          totalDeliveries: leaderboardData?.totalDeliveries,
          totalParticipants: leaderboardData?.totalRiders,
          prize: leaderboardData == null ? '--' : _formatCurrency(leaderboardData.prizeMoney),
          score: leaderboardData?.score,
          payoutDate: 'Paid on 1st of next month',
          scoreBreakdown: _buildBreakdown(leaderboardData),
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

  static List<ScoreBreakdown> _buildBreakdown(LeaderboardStanding? leaderboard) {
    if (leaderboard == null) {
      return const [
        ScoreBreakdown(title: 'Deliveries', formula: '-', points: '--'),
        ScoreBreakdown(title: 'Rating', formula: '-', points: '--'),
        ScoreBreakdown(title: 'On-Time', formula: '-', points: '--'),
      ];
    }

    return [
      ScoreBreakdown(
        title: 'Deliveries',
        formula: '${leaderboard.totalDeliveries} drops',
        points: '${leaderboard.breakdown.deliveriesPoints.toStringAsFixed(0)} pts',
      ),
      ScoreBreakdown(
        title: 'Rating',
        formula: 'Platform rating',
        points: '${leaderboard.breakdown.ratingPoints.toStringAsFixed(0)} pts',
      ),
      ScoreBreakdown(
        title: 'On-Time',
        formula: 'Punctuality',
        points: '${leaderboard.breakdown.onTimePoints.toStringAsFixed(0)} pts',
      ),
    ];
  }

  static String _formatCurrency(double value) {
    final hasFraction = value % 1 != 0;
    final formatted = hasFraction ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
    return '₹$formatted';
  }
}
