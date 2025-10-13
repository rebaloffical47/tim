import gradio as gr
import random
# game state initialization
car_positions = {"You": 0, "AI": 0}
finish_line = 5
current_q = 0
questions = [
    {"q": "What does ABS stand for in cars?", "a": "Anti-lock Braking System"},
    {"q": "Which company makes the Mustang?", "a": "Ford"},
    {"q": "Which fuel is more eco-friendly?", "a": "Electric"},
    {"q": "What does SUV stand for?", "a": "Sport Utility Vehicle"},
    {"q": "Which country is Ferrari from?", "a": "Italy"}
]
def draw_track(car_positions):
    """Helper function to create the race track visualization."""
    you_track = "🚗" + "  " * car_positions["You"]
    ai_track = "🤖" + "  " * car_positions["AI"]
    finish_line_str = "🚩"
    # Ensure the finish line is always visible
    if car_positions["You"] < finish_line:
        you_track += "  " * (finish_line - car_positions["You"] -1 ) + finish_line_str
    else:
        you_track += " " + finish_line_str
    if car_positions["AI"] < finish_line:
        ai_track += "  " * (finish_line - car_positions["AI"] -1) + finish_line_str
    else:
        ai_track += " " + finish_line_str
    return f"You: {you_track}\nAI: {ai_track}"
def start_game():
    """Initializes the game and returns the first question."""
    return (
        f"Question: {questions[0]['q']}\n\n{draw_track({'You': 0, 'AI': 0})}",
        {"You": 0, "AI": 0},
        0,
        gr.update(interactive=True)
    )
def play(answer, car_positions_state, current_q_state):
    """
    Processes a user's answer and updates the game state.
    Args:
        answer (str): The user's answer.
        car_positions_state (dict): The current positions of the cars.
        current_q_state (int): The index of the current question.
    Returns:
        tuple: The updated output text, car positions, and question index.
    """
    # Get the current question to check the answer
    q_index_for_check = current_q_state
    if q_index_for_check >= len(questions):
        return "Game over! Please click restart!", car_positions_state, current_q_state, gr.update(interactive=False)
    q = questions[q_index_for_check]
    # Initialize the response with the question
    response = f"Question: {q['q']}\n"
    # Check user answer
    if answer and answer.strip().lower() == q["a"].lower():
        car_positions_state["You"] += 1
        response += "Correct! Your car moves forward. 🎉\n"
    else:
        response += f"Wrong! The correct answer was: {q['a']}\n"
    # AI logic
    if random.random() > 0.3:
        car_positions_state["AI"] += 1
        response += "AI also moves forward. 🤖\n"
    else:
        response += "AI stayed still. 😴\n"
    # Update the question index for the next turn
    current_q_state += 1

    # Check for winner after the turn
    if car_positions_state["You"] >= finish_line:
        return (
            f"You won the race! 🏆\n\n{draw_track(car_positions_state)}",
            car_positions_state,
            current_q_state,
            gr.update(interactive=False) # Disable input after game ends
        )
    elif car_positions_state["AI"] >= finish_line:
        return (
            f"AI won the race! 😭\n\n{draw_track(car_positions_state)}",
            car_positions_state,
            current_q_state,
            gr.update(interactive=False)
        )
    # If the game is not over, prepare for the next question
    next_q_text = ""
    if current_q_state < len(questions):
        next_q_text = f"\n\nQuestion: {questions[current_q_state]['q']}"
    else:
        # Handle a draw or end of questions
        next_q_text = "\n\nGame over! No more questions."
    return (
        response + next_q_text + f"\n\n{draw_track(car_positions_state)}",
        car_positions_state,
        current_q_state,
        gr.update(value="")
    )
# Gradio UI
with gr.Blocks(title="🚗 Car Trivia Race!") as demo:
    gr.Markdown("# 🚗 Car Trivia Race!")
    gr.Markdown("Answer car trivia to race against AI! First to the finish line wins!")

    # State variables to hold the game state
    car_positions_state = gr.State(car_positions)
    current_q_state = gr.State(current_q)
    game_output = gr.Textbox(
        label="Race Updates",
        lines=5,
        interactive=False,
    )
    user_input = gr.Textbox(
        label="Your Answer",
        placeholder="Type your answer here...",
    )
    submit_btn = gr.Button("Submit Answer")
    restart_btn = gr.Button("Restart Game")
    # Link the components
    submit_btn.click(
        fn=play,
        inputs=[user_input, car_positions_state, current_q_state],
        outputs=[game_output, car_positions_state, current_q_state, user_input]
    )
    restart_btn.click(
        fn=start_game,
        inputs=[],
        outputs=[game_output, car_positions_state, current_q_state, user_input]
    )

    demo.load(start_game, inputs=[], outputs=[game_output, car_positions_state, current_q_state, user_input])
demo.launch()  
