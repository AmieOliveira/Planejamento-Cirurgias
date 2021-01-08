#!/usr/local/bin/python3

import matplotlib.pyplot as plt

def plot_per_day(instance, solution, fo_val, filename="testeDias"):
    LENGTH_DAY = 46

    surgeries, rooms = instance
    sc_d, sc_r, sc_h, e, sg_tt, sc_ts = solution

    fig, ax = plt.subplots(2,3, figsize=(15,2*rooms*4))

    print("All good")