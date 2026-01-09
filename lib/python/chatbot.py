from flask import Flask, request, jsonify
import json
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

app = Flask(__name__)
qa_files = ['qa_data.json', 'bodyweight_qa.json', 'machinebase_qa.json', 'weightbase_qa.json']
qa_data = []

for file_path in qa_files:
    with open(file_path, 'r') as f:
        qa_data.extend(json.load(f))

        questions = [qa['question'].lower() for qa in qa_data]
        vectorizer = TfidfVectorizer()
        question_vectors = vectorizer.fit_transform(questions)
        
# Load Q&A data once
# with open('qa_data.json', 'r') as f:
#     qa_data = json.load(f)
#     # Prepare TF-IDF model
#     questions = [qa['question'].lower() for qa in qa_data]
#     vectorizer = TfidfVectorizer()
#     question_vectors = vectorizer.fit_transform(questions)


# Chatbot state (for simplicity; for production use, implement session-based logic)
chat_state = {"awaiting_bmi": False}

def extract_weight_height(text):
    weight_match = re.search(r'(\d{2,3})\s*kg', text)
    height_match = re.search(r'(\d{2,3})\s*cm', text)
    weight = int(weight_match.group(1)) if weight_match else None
    height = int(height_match.group(1)) if height_match else None
    return weight, height

def calculate_bmi(weight, height_cm):
    height_m = height_cm / 100
    return weight / (height_m ** 2)

def bmi_category(bmi):
    if bmi < 18.5:
        return "Underweight"
    elif 18.5 <= bmi < 25:
        return "Normal weight"
    elif 25 <= bmi < 30:
        return "Overweight"
    else:
        return "Obese"

def find_answer(user_input):
    input_vec = vectorizer.transform([user_input])
    similarities = cosine_similarity(input_vec, question_vectors).flatten()
    best_match_idx = np.argmax(similarities)
    if similarities[best_match_idx] > 0.4:  # tweak threshold as needed
        return qa_data[best_match_idx]['answer']
    return None


@app.route("/chat", methods=["POST"])
def chat():
    user_input = request.json.get("message", "").lower()

    weight, height = extract_weight_height(user_input)

    if "bmi" in user_input:
        if weight and height:
            bmi = calculate_bmi(weight, height)
            category = bmi_category(bmi)
            return jsonify({"reply": f"Your BMI is {bmi:.1f} ({category})"})
        else:
            chat_state["awaiting_bmi"] = True
            return jsonify({"reply": "I need weight, height to calculate this. Could you provide them?"})

    matched = find_answer(user_input)
    if chat_state["awaiting_bmi"] and matched:
        chat_state["awaiting_bmi"] = False
        return jsonify({"reply": matched})

    if chat_state["awaiting_bmi"]:
        if weight and height:
            bmi = calculate_bmi(weight, height)
            category = bmi_category(bmi)
            chat_state["awaiting_bmi"] = False
            return jsonify({"reply": f"Your BMI is {bmi:.1f} ({category})"})
        else:
            return jsonify({"reply": "Please provide your weight (kg) and height (cm), e.g., '65kg 166cm'."})

    if matched:
        return jsonify({"reply": matched})

    return jsonify({"reply": "I'm not sure about that. Try rephrasing your question :)"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
