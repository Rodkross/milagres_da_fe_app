import os
import google.generativeai as genai
import sys

# Replace with the user's API Key
os.environ["GEMINI_API_KEY"] = "AIzaSyBj1SJ2pGItpaWdKNAQfaGTPIkI-ckgaVo"
genai.configure(api_key=os.environ["GEMINI_API_KEY"])

try:
    model = genai.GenerativeModel('gemini-1.5-flash')
    response = model.generate_content("Say hello")
    print(response.text)
except Exception as e:
    print("Error:", e)
    sys.exit(1)
