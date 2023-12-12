from results_loader import ResultsLoader
from results_plotter import ResultsPlotter

class ResultsAnalyzer:
  def __init__(self, directory, benchmark_app, annotation, experiments):
    self.loader = ResultsLoader(directory)
    self.plotter = None
    self.directory = directory
    self.benchmark_app = benchmark_app
    self.annotation = annotation
    self.experiments_filter = experiments.split(',')

  # ad-hoc approach to get the variants and verify all the experiments have the same ones
  def fetch_experiment_variants(self):
    variants = []
    for experiment, experiment_data in self.plotter.data.items():
      if variants != []:
        assert (variants == list(experiment_data.keys())), \
          "Experiments have different variants - not able to create a grouped plot"
      else:
        variants = list(experiment_data.keys())
    return self.plotter.fix_variants_order(variants)

  def analyze(self):
    data = self.loader.load_data(self.experiments_filter)
    self.plotter = ResultsPlotter(data, self.benchmark_app)

  def plot_results(self, axes, xaxis, legend_loc, plot_idx=None):
    if not self.plotter:
      print("Plotter is not instatiated. Please analyze the results first.")
      exit()
    if axes is None:
      print("Axes for the figure are not provided")
      exit()

    if xaxis == "threads":
      for experiment, experiment_data in self.plotter.data.items():
        if plot_idx is None:
          self.plotter.plot_bars_threads(axes, experiment, experiment_data, self.directory, self.annotation, legend_loc)
        else:
          self.plotter.plot_bars_threads(axes[plot_idx], experiment, experiment_data, self.directory, self.annotation, legend_loc)
          plot_idx += 1
    elif xaxis == "experiments":
      if plot_idx is None:
        self.plotter.plot_bars_experiments(axes, self.directory, self.annotation, legend_loc)
      else:
        self.plotter.plot_bars_experiments(axes[plot_idx], self.directory, self.annotation, legend_loc)
        plot_idx += 1

    return plot_idx  