#!/usr/bin/env python3
"""Classify user messages and inject routing hints for Kiro agents.

Kiro userPromptSubmit hook. Reads JSON from stdin, classifies the user's
prompt, and outputs routing hints as additional context.
"""
import json
import sys
import re

SIGNALS = [
    {
        "name": "DECISION",
        "message": "DECISION detected — consider creating a Decision Record in work/active/ and logging in work/Index.md",
        "patterns": [
            "decided", "deciding", "decision", "we chose", "agreed to",
            "let's go with", "the call is", "we're going with",
            "決定した", "決めた", "合意した",
            "결정했어", "결정했습니다", "합의했어",
            "决定了", "我们决定", "确定了", "同意",
        ],
    },
    {
        "name": "INCIDENT",
        "message": "INCIDENT detected — consider swapping to incident mode (/agent swap incident) or creating a note in work/incidents/",
        "patterns": [
            "incident", "outage", "pagerduty", "severity",
            "p0", "p1", "p2", "sev1", "sev2", "postmortem", "rca",
            "インシデント", "障害",
            "인시던트", "장애",
            "事件", "故障", "事后分析",
        ],
    },
    {
        "name": "1:1 CONTENT",
        "message": "1:1 CONTENT detected — consider creating a 1-on-1 note in work/1-1/ and updating org/people/",
        "patterns": [
            "1:1", "1-1", "1-on-1", "one on one", "1on1",
            "catch up with", "sync with",
            "ワンオンワン", "원온원", "一对一", "单独面谈",
        ],
    },
    {
        "name": "WIN",
        "message": "WIN detected — consider adding to perf/Brag Doc.md with evidence links",
        "patterns": [
            "shipped", "launched", "completed", "released", "deployed",
            "achieved", "won", "promoted", "praised", "win",
            "kudos", "shoutout", "great feedback", "recognized",
            "出荷した", "リリースした", "達成した", "褒められた",
            "배포했어", "출시했어", "달성했어", "칭찬받았어",
            "发布了", "上线了", "完成了", "表扬", "认可",
        ],
    },
    {
        "name": "ARCHITECTURE",
        "message": "ARCHITECTURE discussion — consider creating a reference note in reference/ or a decision record",
        "patterns": [
            "architecture", "system design", "rfc", "tech spec",
            "trade-off", "design doc", "adr",
            "アーキテクチャ", "システム設計",
            "아키텍처", "시스템 설계",
            "架构", "系统设计", "技术规范",
        ],
    },
    {
        "name": "PERSON CONTEXT",
        "message": "PERSON CONTEXT detected — consider updating the relevant person note in org/people/",
        "patterns": [
            "told me", "said that", "feedback from", "met with",
            "talked to", "spoke with", "mentioned that",
            "言ってた", "フィードバック", "話した",
            "말했어", "피드백", "얘기했어",
            "说了", "提到", "反馈",
        ],
    },
    {
        "name": "PROJECT UPDATE",
        "message": "PROJECT UPDATE detected — consider updating the active work note in work/active/",
        "patterns": [
            "project update", "sprint", "milestone",
            "shipped", "launched", "completed", "released", "deployed",
            "went live", "rolled out", "merged",
            "スプリント", "マイルストーン",
            "스프린트", "마일스톤",
            "迭代", "里程碑",
        ],
    },
]


def _match(patterns, text):
    for phrase in patterns:
        if re.search(r'(?<![a-zA-Z])' + re.escape(phrase) + r'(?![a-zA-Z])', text):
            return True
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    prompt = data.get("prompt", "")
    if not prompt:
        sys.exit(0)

    signals = [s["message"] for s in SIGNALS if _match(s["patterns"], prompt.lower())]

    if signals:
        hints = "\n".join(f"- {s}" for s in signals)
        print(f"Content classification hints:\n{hints}\nFollow AGENTS.md conventions.")

    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(0)
