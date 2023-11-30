from results_loader import ResultsLoader
from results_plotter import ResultsPlotter

class ResultsAnalyzer:
  def __init__(self, directory, benchmark_app, plot_type, annotation):
    self.loader = ResultsLoader(directory)
    self.plotter = None
    self.directory = directory
    self.benchmark_app = benchmark_app
    self.plot_type = plot_type
    self.annotation = annotation

  def analyze(self):
    data = self.loader.load_data()
    self.plotter = ResultsPlotter(data, self.benchmark_app)

  def plot_results(self):
    if self.plotter:
      if self.plot_type == "bar":
        self.plotter.plot_bar_chart(self.directory, self.annotation) # save bar plots in the benchmark directory
        self.plotter.plot_group_bar_chart(self.directory, self.annotation) # save bar plots in the benchmark directory
      elif self.plot_type == "line":
        self.plotter.plot_line_chart(self.directory, self.annotation) # save line plots in the benchmark directory
    else:
      print("Plotter is not instatiated. Please analyze the results first.")
      exit()