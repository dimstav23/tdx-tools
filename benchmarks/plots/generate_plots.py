import argparse
from results_analyzer import ResultsAnalyzer

def main():
  parser = argparse.ArgumentParser(description='Produce plots for Gramine-TDX.')
  parser.add_argument('--directory', '-d', required=True, help='Directory containing CSV files.')
  parser.add_argument('--app', '-a', required=True, help='Name of the application for the plot title.')
  parser.add_argument('--type', '-t', default='individual', choices=['individual', 'group'],
                      help='Choose the plot type. \
                        Individual indicates that each experiment gets its own figure. \
                        Group indicates that the plots are combined in a single figure.')
  parser.add_argument('--annotation', '-n', default=None, choices=['absolute', 'overhead'], help='Annotation type')
  parser.add_argument('--experiments', '-e', default=None, 
                      help='Comma spearated list to choose specific experiments to plot -- case sensitive')
  parser.add_argument('--xaxis', '-x', default='threads', choices=['threads', 'experiments'],
                      help='Choose x-axis type. Note that "experiments" type is only available for single-threaded results.')
  parser.add_argument('--legend_loc', '-l', default=None,
                      help='Choose the location of the legend. Note that in case of a group plot, it applies to the first subplot.')

  args = parser.parse_args()

  print("Generating " + args.type + " plot for " + args.app + " with " + args.xaxis + " as x-axis")
  analyzer = ResultsAnalyzer(args.directory, args.app, args.annotation, args.experiments)
  analyzer.analyze()
  analyzer.plot_results(args.type, args.xaxis, args.legend_loc)

if __name__ == "__main__":
  main()