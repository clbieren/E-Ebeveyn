import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/ai_coach_provider.dart';
import '../providers/ai_credit_provider.dart';
import '../services/ad_mob_service.dart';
import 'widgets/ai_chat_bubble.dart';
import 'widgets/analyze_button_widget.dart';

class AiInsightScreen extends HookConsumerWidget {
  const AiInsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiCoachProvider);
    final credits = ref.watch(aiCreditProvider);
    final controller = useTextEditingController();

    useEffect(() {
      AdMobService().loadRewardedAd();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Bebek Koçu'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '❤️ $credits',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Yeni sohbet',
            onPressed: aiState.isLoading
                ? null
                : () =>
                    ref.read(aiCoachProvider.notifier).startNewConversation(),
            icon: const Icon(Icons.add_comment_rounded),
          ),
          IconButton(
            tooltip: 'Geçmiş konuşmalar',
            onPressed: () => _showHistorySheet(context, ref, aiState),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: AnalyzeButtonWidget(
                isLoading: aiState.isLoading,
                onPressed: () async {
                  final hasCredit =
                      await ref.read(aiCreditProvider.notifier).useCredit();
                  if (hasCredit) {
                    ref.read(aiCoachProvider.notifier).analyzeLast3Days();
                  } else {
                    if (!context.mounted) return;
                    _showOutOfCreditsDialog(context, ref);
                  }
                },
              ),
            ),
            Expanded(
              child: aiState.messages.isEmpty && aiState.isLoading
                  ? const _AiSkeleton()
                  : aiState.messages.isEmpty
                      ? Center(
                          child: Text(
                            'Mesaj yaz ya da Son 3 gun verisini analiz etmek icin butona bas.',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          itemCount: aiState.messages.length +
                              (aiState.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (aiState.isLoading &&
                                index == aiState.messages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            }

                            final msg = aiState.messages[index];
                            return Align(
                              alignment: msg.role == AiChatRole.user
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: AiChatBubble(markdownText: msg.text),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: aiState.isLoading
                          ? null
                          : (value) async {
                              final text = value.trim();
                              if (text.isEmpty) return;
                              final hasCredit = await ref
                                  .read(aiCreditProvider.notifier)
                                  .useCredit();
                              if (hasCredit) {
                                await ref
                                    .read(aiCoachProvider.notifier)
                                    .sendMessage(text);
                                controller.clear();
                              } else {
                                if (!context.mounted) return;
                                _showOutOfCreditsDialog(context, ref);
                              }
                            },
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yaz...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: aiState.isLoading
                        ? null
                        : () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;
                            final hasCredit = await ref
                                .read(aiCreditProvider.notifier)
                                .useCredit();
                            if (hasCredit) {
                              await ref
                                  .read(aiCoachProvider.notifier)
                                  .sendMessage(text);
                              controller.clear();
                            } else {
                              if (!context.mounted) return;
                              _showOutOfCreditsDialog(context, ref);
                            }
                          },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showHistorySheet(
  BuildContext context,
  WidgetRef ref,
  AiCoachState aiState,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      if (aiState.histories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Henüz kayıtlı bir konuşma yok.'),
        );
      }
      return ListView.separated(
        itemCount: aiState.histories.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final history = aiState.histories[index];
          return ListTile(
            title: Text(history.title),
            subtitle: Text(
              '${history.createdAt.day.toString().padLeft(2, '0')}.'
              '${history.createdAt.month.toString().padLeft(2, '0')}.'
              '${history.createdAt.year}  '
              '${history.createdAt.hour.toString().padLeft(2, '0')}:'
              '${history.createdAt.minute.toString().padLeft(2, '0')}',
            ),
            onTap: () {
              ref.read(aiCoachProvider.notifier).loadConversation(history.id);
              Navigator.of(ctx).pop();
            },
          );
        },
      );
    },
  );
}

class _AiSkeleton extends StatelessWidget {
  const _AiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          ShimmerSkeleton(height: 14, width: double.infinity),
          SizedBox(height: 12),
          ShimmerSkeleton(height: 14, width: double.infinity),
          SizedBox(height: 12),
          ShimmerSkeleton(height: 14, width: double.infinity),
          SizedBox(height: 12),
          ShimmerSkeleton(height: 14, width: double.infinity),
          SizedBox(height: 12),
          ShimmerSkeleton(height: 14, width: double.infinity),
        ],
      ),
    );
  }
}

void _showOutOfCreditsDialog(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite_rounded,
                size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Harika Bir İş Çıkardın!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bugün bebeğin için çok önemli bilgiler öğrenerek büyük bir fedakarlık yaptın. Günlük 3 soruluk ücretsiz kullanım limitine ulaştın.\n\nDaha fazla bilgi için reklam izleyerek hak kazanabilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.ondemand_video_rounded),
              label: const Text('Reklam İzle & 1 Hak Kazan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                AdMobService().showRewardedAd(
                  onEarnedReward: () {
                    ref.read(aiCreditProvider.notifier).earnCredit();
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
