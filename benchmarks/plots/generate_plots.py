import argparse
from results_analyzer import ResultsAnalyzer

def main():
  parser = argparse.ArgumentParser(description='Produce plots for Gramine-TDX.')
  parser.add_argument('--directory', '-d', required=True, help='Directory containing CSV files.')
  parser.add_argument('--app', '-a', required=True, help='Name of the application for the plot title.')
  parser.add_argument('--type', '-t', default='bar', choices=['bar', 'line'], help='Plot type')
  parser.add_argument('--annotation', '-n', default=None, choices=['absolute', 'overhead'], help='Annotation type')

  args = parser.parse_args()

  analyzer = ResultsAnalyzer(args.directory, args.app, args.type, args.annotation)
  analyzer.analyze()
  analyzer.plot_results()

if __name__ == "__main__":
  main()