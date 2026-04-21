class PromptService {
  static String buildSystemPrompt() {
    return [
      "You are a strict quiz JSON generator.",
      "",
      "You must output ONLY valid JSON.",
      "Do NOT include markdown.",
      "Do NOT include explanations outside the JSON.",
      "Do NOT include code fences.",
      "Do NOT include commentary.",
      "",
      "You must use ONLY information found in the provided content.",
      "If insufficient information exists, reduce the question count.",
      "",
      "All math must use LaTeX delimiters:",
      "Inline: \\( ... \\)",
      "Block: \\[ ... \\]",
      "",
      "Follow the exact schema provided.",
      "Do not add extra properties.",
      "Do not remove required properties.",
      "Do not rename fields.",
      "Keep explanations short and factual.",
      "Ensure MCQ answerIndex is a number referencing choices array.",
      "Ensure true_false answerIndex is 0 for True or 1 for False.",
      "Ensure matching pairs are unique.",
      "Ensure fill_blank prompts contain '____'.",
      "Return JSON only."
    ].join("\n");
  }

  static String buildUserPrompt({
    required String quizType,
    required int questionCount,
    required String difficulty,
    required String content,
  }) {
    final schemaString = '''
{
  "quiz_title": "string",
  "quiz_type": "string",
  "question_count": number,
  "source_summary": "string",
  "questions": [
    {
      "id": "string",
      "type": "mcq | true_false | fill_blank | identification | matching",
      "prompt": "string",
      "choices": ["string"],
      "answerIndex": number,
      "answers": ["string"],
      "pairs": [{"left": "string", "right": "string"}],
      "explanation": "string"
    }
  ]
}
''';

    return [
      "Generate an exam-ready quiz using the source material.",
      "Source Material:",
      content,
      "",
      "Requested Parameters:",
      "quizType: $quizType",
      "questionCount: $questionCount",
      "difficulty: $difficulty",
      "",
      "CRITICAL TYPE RULES:",
      "- The returned top-level field \"quiz_type\" must exactly equal \"$quizType\".",
      "- If quizType != \"Mixed\", then ALL questions must have question.type matching the requested type (mcq for Multiple Choice, etc).",
      "",
      "COUNT RULES:",
      "- question_count MUST equal questions.length.",
      "- If there is insufficient material to generate the requested count, reduce question_count and return fewer questions.",
      "",
      "NO HALLUCINATIONS:",
      "- Use ONLY source content provided above.",
      "- Do not invent facts.",
      "",
      "JSON-PARSING GUARANTEE:",
      "- Entire response must be valid JSON.",
      "- No extra text before or after JSON.",
      "",
      "MCQ RULES:",
      "- Provide >= 4 choices.",
      "- Ensure answerIndex is valid and points to the correct choice.",
      "",
      "TRUE/FALSE RULES:",
      "- choices must be exactly [\"True\", \"False\"].",
      "- answerIndex must be 0 (True) or 1 (False).",
      "",
      "FILL BLANK RULES:",
      "- Prompt must include ____ where blank is.",
      "- answers[] contains accepted answers.",
      "",
      "IDENTIFICATION RULES:",
      "- answers[] contains accepted answers.",
      "",
      "MATCHING RULES:",
      "- Provide 4–10 pairs.",
      "- Ensure no repeated left or right.",
      "",
      "Schema (follow exactly):",
      schemaString
    ].join("\n");
  }

  static String buildReviewerPrompt(String content) {
    return '''
Please provide comprehensive reviewer notes for the following content.
Focus on:
1. Key concepts and definitions
2. Important points to remember
3. Common misconceptions
4. Real-world applications

All mathematical equations or formulas MUST be wrapped in LaTeX delimiters:
Inline math: \\( ... \\)
Block math: \\[ ... \\]

Content:
$content

IMPORTANT: Provide the notes in a structured, organized plain text format. Do not use Markdown headers like # or bolding like **. Use plain text and bullet points (•).
''';
  }

  static String buildFlashcardPrompt(String content) {
    return '''
Create flashcards from the following content. Each flashcard should have:
- Front (question/concept)
- Back (answer/explanation)

Format your response as a JSON array like this:
[
  {"front": "Question 1", "back": "Answer 1"},
  {"front": "Question 2", "back": "Answer 2"}
]

Content:
$content

Generate 10-15 flashcards. Return JSON only.
''';
  }

  static String buildExplanationPrompt({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required String context,
  }) {
    return '''
Provide a helpful explanation for the following quiz question.
Context: $context
Question: $question
User's Answer: $userAnswer
Correct Answer: $correctAnswer

Explain why the correct answer is right and why the user's answer might be wrong or partially correct.
Keep it encouraging and educational. Use LaTeX for any formulas.
''';
  }
}
