#example1 
!pip install -q --upgrade gradio 
import gradio as gr
def check_number(number):
    if number % 2 == 0:
        return "Even"
    else:
        return "Odd"
demo= gr.Interface(
    fn=check_number,
    inputs=gr.Number(label="Enter a number"),
    outputs="text",
    title="Number Odd or Even",
    description="Type a number and it will tell if it is odd or even"
)
demo.launch()

#example 2
import gradio as gr
import matplotlib.pyplot as plt
options = ["Python", "Java Script", "C++", "Java"]
votes = {}
for opt in options:
  votes[opt] = 0 # setting the starting votes to zero
def vote(option):
  votes[option]= votes[option] +1       #increase the votes for the chosen options
  #make a bar chart of the results
  fig, ax = plt.subplots()
  ax.bar(votes.keys(),votes.values())
  ax.set_ylabel=("Votes")
  ax.set_title=("Live Poll results")
  return fig
#step 4
with gr.Blocks() as demo:
  gr.Markdown("## App\n vote for your favourite programming language")
  output_Plot = gr.Plot()
  #make a row for each button(one for each option)
  with gr.Row():
    for opt in options:
      gr.Button(opt).click(fn=vote,inputs=gr.State(opt),outputs=output_Plot)
  demo.launch()



