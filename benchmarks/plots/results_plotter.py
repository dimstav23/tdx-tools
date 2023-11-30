import sys
import matplotlib.pyplot as plt
import numpy as np

import matplotlib
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

import seaborn as sb
palette = sb.color_palette("pastel")
colour = palette
hatch = ["", "//", "..", "", "++", "", "", "//", "..", "", "++", ""]
markers = ['o', 's', '+', 'x', 'D', '*']

variants_plot_sequence = [
  "Native",
  "Normal VM",
  "Intel TDX VM",
  "Gramine-SGX",
  "Gramine-VM",
  "Gramine-TDX",
]

class ResultsPlotter:
  def __init__(self, data, benchmark_app):
    self.data = data
    self.benchmark_app = benchmark_app

  def fix_variants_order(self, variants):
    # variants is the original list of variants in random order
    # variants_plot_sequence is the sequence we want for the bars

    # get the existing labeled variants and put them in the desired order
    labeled_variants = [variant for variant in variants_plot_sequence if variant in variants]
    # get the rest of the variants without a specified label
    unlabeled_variants = [variant for variant in variants if variant not in labeled_variants]

    return labeled_variants + unlabeled_variants

  def annotate_abs_values(self, axes, bars, data, y_lim):
    fontsize = 6
    for bar, value in zip(bars, data):\
      t = axes.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02 * y_lim, f'{value:.3f}', 
                  in_layout=True, ha='center', va='bottom', rotation='vertical', fontsize=fontsize)
    # return the top position of the annotation to increase the ylimit if needed
    return t.get_window_extent().transformed(axes.transData.inverted()).y1

  def annotate_overhead(self, axes, bars, baseline_data, data, y_lim):
    fontsize = 6
    for idx, (bar, value) in enumerate(zip(bars, data)):
      t = axes.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02 * y_lim, f'{value/baseline_data[idx]:.2f}', 
                in_layout=True, ha='center', va='bottom', rotation='vertical', fontsize=fontsize)
    # return the top position of the annotation to increase the ylimit if needed
    return t.get_window_extent().transformed(axes.transData.inverted()).y1

  def plot_bar_chart(self, save_path=None, annotation=None):  
    for experiment, experiment_data in self.data.items():
      fig, axes = plt.subplots(figsize=(10, 6))

      variants = list(experiment_data.keys()) # number of bars per data point
      thread_values = list(experiment_data[variants[0]].index) # nmuber of data points

      bar_area_percentage = 0.8 # bar width to cover 80% of the dedicated space
      width = float(bar_area_percentage / len(variants)) # width of each bar
      x = np.arange(len(thread_values)) # number of xaxis ticks
      x_spacing = np.linspace(-bar_area_percentage/2 + width/2, bar_area_percentage/2 - width/2, num=len(variants)) # position of each x-tick

      # sort the variants for the bar plots
      sorted_variants = self.fix_variants_order(variants)

      # plot the bars
      bars = []
      for i, variant in enumerate(sorted_variants):
        data = experiment_data[variant].to_numpy().flatten() # values to be plotted
        bars.append(axes.bar(x + x_spacing[i], data, width=width, label=variant, 
                        color = colour[i], hatch=hatch[i], edgecolor='black'))
        
      # add annotation above the bar
      _, y_lim = axes.get_ylim() # get the y_lim to adjust the annotation height
      y_limits = [y_lim] # create a list of the text y_limits to update the ylim of the plot if needed
      for i, variant in enumerate(sorted_variants):
        data = experiment_data[variant].to_numpy().flatten() # retrieve the values
        if annotation == "absolute":
          y_limits.append(self.annotate_abs_values(axes, bars[i], data, y_lim))
        elif annotation == "overhead": # overhead annotation to the native value
          baseline_variant = "Native"
          if baseline_variant not in experiment_data.keys(): # check if native variant is provided
            sys.exit("Overhead annotation specified but \"native\" variant is not provided.")
          baseline_data = experiment_data[baseline_variant].to_numpy().flatten() # baseline values
          y_limits.append(self.annotate_overhead(axes, bars[i], baseline_data, data, y_lim))   
      axes.set_ylim(_, max(y_limits) + 0.04 * max(y_limits)) # increase the y_lim in case the text goes beyond the border
      
      # if we have a single thread value, do not print xlabel
      if len(thread_values) == 1:
        plt.xticks([])
      else:
        plt.xlabel('Threads')
        plt.xticks(range(0, len(thread_values)), thread_values)
      
      plt.ylabel(experiment_data[variant].keys()[0])
      plt.title(self.benchmark_app)

      fig.legend(labels=sorted_variants, ncols=len(variants), loc="upper center", fontsize="small")
      filename = save_path + "/" + self.benchmark_app + "_bar_" + experiment
      plt.savefig(filename + ".pdf", dpi=300, format='pdf', bbox_inches='tight')
      plt.savefig(filename + ".png", dpi=300, format='png', bbox_inches='tight')

  def plot_group_bar_chart(self, save_path=None, annotation=None):
    
    # prepare the subplot layout
    num_experiments = len(self.data.items())
    if (num_experiments == 1):
      print("Group plot omitted --- single experiment")
      return
    fig, axes = plt.subplots(1, num_experiments, figsize=(6 * num_experiments, 4))
    plot_idx = 0

    for experiment, experiment_data in self.data.items():
      variants = list(experiment_data.keys()) # number of bars per data point
      thread_values = list(experiment_data[variants[0]].index) # nmuber of data points

      bar_area_percentage = 0.8 # bar width to cover 80% of the dedicated space
      width = float(bar_area_percentage / len(variants)) # width of each bar
      x = np.arange(len(thread_values)) # number of xaxis ticks
      x_spacing = np.linspace(-bar_area_percentage/2 + width/2, bar_area_percentage/2 - width/2, num=len(variants)) # position of each x-tick

      # sort the variants for the bar plots
      sorted_variants = self.fix_variants_order(variants)

      # plot the bars
      bars = []
      for i, variant in enumerate(sorted_variants):
        data = experiment_data[variant].to_numpy().flatten() # values to be plotted
        bars.append(axes[plot_idx].bar(x + x_spacing[i], data, width=width, label=variant, 
                                  color = colour[i], hatch=hatch[i], edgecolor='black'))

      # add annotation above the bar
      _, y_lim = axes[plot_idx].get_ylim() # get the y_lim to adjust the annotation height
      y_limits = [y_lim] # create a list of the text y_limits to update the ylim of the plot if needed
      for i, variant in enumerate(sorted_variants):
        data = experiment_data[variant].to_numpy().flatten() # retrieve the values
        if annotation == "absolute":
          y_limits.append(self.annotate_abs_values(axes[plot_idx], bars[i], data, y_lim))
        elif annotation == "overhead": # overhead annotation to the native value
          baseline_variant = "Native"
          if baseline_variant not in experiment_data.keys(): # check if native variant is provided
            sys.exit("Overhead annotation specified but \"native\" variant is not provided.")
          baseline_data = experiment_data[baseline_variant].to_numpy().flatten() # baseline values
          y_limits.append(self.annotate_overhead(axes[plot_idx], bars[i], baseline_data, data, y_lim))
      axes[plot_idx].set_ylim(_, max(y_limits) + 0.04 * max(y_limits)) # increase the y_lim in case the text goes beyond the border

      # if we have a single thread value, do not print xlabel
      if len(thread_values) == 1:
        axes[plot_idx].set_xticks([])
      else:
        axes[plot_idx].set_xlabel('Threads')
        axes[plot_idx].set_xticks(range(0, len(thread_values)), thread_values)
      
      axes[plot_idx].set_ylabel(experiment_data[variant].keys()[0])
      axes[plot_idx].set_title(self.benchmark_app + " - " + experiment)
      plot_idx = plot_idx + 1 # increase the plot index for the subplots

    # fig.subplots_adjust(wspace=0.1, hspace=0)
    fig.legend(labels=sorted_variants, ncols=len(variants), loc="upper center", fontsize="small")
    filename = save_path + "/" + self.benchmark_app + "_group_bar"
    plt.savefig(filename + ".pdf", dpi=300, format='pdf', bbox_inches='tight')
    plt.savefig(filename + ".png", dpi=300, format='png', bbox_inches='tight')

  def plot_line_chart(self, save_path=None, annotation=None):
    for experiment, experiment_data in self.data.items():
      plt.figure(figsize=(10, 6))

      variants = list(experiment_data.keys())
      thread_values = list(experiment_data[variants[0]].index)

      for i, variant in enumerate(variants):
        data = experiment_data[variant].to_numpy().flatten() # values to be plotted
        plt.plot(thread_values, data, label=variant, color = colour[i], marker=markers[i])

      plt.xlabel('Threads')
      plt.xticks(thread_values)
      plt.ylabel(experiment_data[variant].keys()[0])
      plt.title(self.benchmark_app)
      plt.legend()

      filename = save_path + "/" + self.benchmark_app + "_line_" + experiment
      plt.savefig(filename + ".pdf", dpi=300, format='pdf', bbox_inches='tight')
      plt.savefig(filename + ".png", dpi=300, format='png', bbox_inches='tight')