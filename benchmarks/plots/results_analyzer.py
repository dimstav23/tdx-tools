from results_loader import ResultsLoader
from results_plotter import ResultsPlotter

class ResultsAnalyzer:
  def __init__(self, directory, benchmark_app, annotation, experiments):
    self.loader = ResultsLoader(directory)
    self.plotter = None
    self.directory = directory
    self.benchmark_app = benchmark_app
    self.annotation = annotation
    self.experiments_filter = experiments.split(',') if experiments is not None else None

  def analyze(self):
    data = self.loader.load_data(self.experiments_filter)
    self.plotter = ResultsPlotter(data, self.benchmark_app)

  def plot_results(self, type, xaxis, legend_loc):
    if not self.plotter:
      print("Plotter is not instatiated. Please analyze the results first.")
      exit()

    if type == "individual":
      if xaxis == "threads":
        self.plotter.plot_bars_threads(self.directory, self.annotation, legend_loc) # save bar plots in the benchmark directory
      elif xaxis == "experiments":
        self.plotter.plot_bars_experiments(self.directory, self.annotation, legend_loc)
      else:
        print("Specified xaxis type is not valid. Please choose between \"threads\" and \"experiments\".")
        exit()
    elif type == "group":
      if xaxis != "threads":
        print("\"group\" plot type is only supported for \"threads\" as its xaxis.")
        exit()
      self.plotter.plot_bars_threads_grouped(self.directory, self.annotation, legend_loc) # save bar plots in the benchmark directory    
    else:
      print("Specified plot type is not valid. Please choose between \"individual\" and \"group\".")
      exit()