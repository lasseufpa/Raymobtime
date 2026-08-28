---
title: 'Raymobtime: A Reproducible Framework for Mobility-Aware mmWave Dataset Generation via Integrated Ray Tracing and Traffic Simulation'

tags:
  - Raymobtime
  - Python
  - wireless communications
  - ray tracing
  - simulation
  - mmWave
  - 5G
  - 6G
  - mobility
  - multimodal datasets

authors:
  - name: Amir Khatibi
    # orcid: 0000-0002-3051-4956
    affiliation: 1
    corresponding: true
    # email: amir.khatibi@land.ufrj.br

  - name: Genivaldo Charchar da Silva
  # orcid: 0009-0006-1033-9026
    affiliation: 2
    # email: genivaldo.silva@itec.ufpa.br

  - name: Gabriel Ferreira Vieira
    # orcid: 0009-0006-1033-9026
    affiliation: 2
    # email: gabriel.vieira@itec.ufpa.br

  - name: Jessica de Keeflen Silva da Silva
    affiliation: 2
    # email: jessica.keeflen@itec.ufpa.br

  - name: Sávio Bastos
    # orcid: 0009-0005-2955-2815
    affiliation: 2
    # email: savio.bastos@itec.ufpa.br

  - name: Ilan Correa
    # orcid: 0000-0002-7219-8226
    affiliation: 2
    # email: ilan@ufpa.br

  - name: José Ferreira de Rezende
    # orcid: 0000-0002-5660-6488
    affiliation: 1
    # email: rezende@land.ufrj.br
    # alternate email: jose.rezende@rnp.br

  - name: Aldebaro Klautau
    # orcid: 0000-0001-7773-2080
    affiliation: 2
    # email: aldebaro@ufpa.br

affiliations:
  - index: 1
    name: Universidade Federal do Rio de Janeiro, Brazil
  - index: 2
    name: Universidade Federal do Pará, Brazil

date: 28 August 2026
bibliography: paper.bib
---

# Summary

`Raymobtime` is an open-source framework for generating realistic, mobility-aware wireless datasets for millimeter-wave (mmWave) and related wireless communication research. It provides a unified and reproducible workflow for combining mobility, three-dimensional environments, electromagnetic propagation, and multimodal sensing information.

Raymobtime combines traffic mobility, three-dimensional environments, radio-propagation simulations, and multimodal sensing within a common dataset-generation workflow. The resulting datasets may include mobility traces, beamforming and channel information, RGB images, and LiDAR point clouds, with spatial and temporal consistency across the generated modalities, supporting research in 5G, 6G, and beyond.

The framework supports both complete simulation execution and the reuse of previously simulated runs. When compatible simulation outputs are already available, Raymobtime can execute data-processing, feature-extraction, and post-processing stages without repeating computationally expensive ray-tracing simulations. Alternatively, when the required external simulators are available, the complete simulation workflow can be executed to generate and organize new synchronized multimodal datasets.

# Statement of Need

The evolution of 5G, 6G, and future wireless systems has increased the need for realistic propagation data at millimeter-wave and sub-terahertz frequencies. Real-world measurements in these bands are costly, time-consuming, and difficult to reproduce across diverse environments, making high-fidelity simulation an important alternative for developing and evaluating wireless communication algorithms.

Generating realistic wireless datasets requires combining accurate mobility, three-dimensional environments, electromagnetic propagation, and, increasingly, sensing information. In practice, these components are often produced by heterogeneous tools and connected through scenario-specific scripts, resulting in fragmented workflows that are difficult to reproduce and maintain. Temporal consistency is also essential for time-dependent problems such as beam tracking, channel prediction, and multimodal learning.

Raymobtime addresses these challenges through a unified workflow that integrates mobility generation, three-dimensional modeling, ray tracing, sensing simulation, data processing, and post-processing. Its episode-and-scene organization explicitly preserves temporal relationships across simulation outputs and derived dataset representations. The framework also separates simulation execution from dataset construction, allowing compatible outputs from previously simulated runs to be reprocessed without repeating computationally expensive ray-tracing stages.

The primary target audience comprises researchers and engineers working on data-driven wireless communications, particularly beam management, channel prediction, integrated sensing and communication, multimodal learning, and related 5G/6G research problems.

# State of the Field

Several platforms provide complementary capabilities for mobility-aware wireless research. Experimental initiatives such as DeepSense 6G [@Alkhateeb2023DeepSense] provide synchronized multimodal sensing and communication measurements for studying beam prediction, blockage, positioning, and related learning tasks. However, the number of effectively distinct scenarios remains relatively small, and dataset diversity is constrained by factors such as the prevalence of line-of-sight (LoS) conditions.

Ray-tracing platforms such as Wireless InSite and Sionna RT [@Hoydis2023SionnaRT] increasingly support mobile transceivers and dynamic scenes, enabling the analysis of time-varying propagation. However, their support for moving scatterers remains limited or unavailable, restricting their ability to accurately model highly dynamic propagation environments.

Raymobtime addresses this complementary problem by coupling specialized traffic simulation with three-dimensional modeling, electromagnetic ray tracing, sensing simulation, and dataset post-processing. Rather than replacing modern ray-tracing tools, it uses them as propagation engines while delegating detailed mobility generation to SUMO [@Krajzewicz2012SUMO]. This design enables reproducible, temporally consistent multimodal datasets with realistic traffic behavior and reusable simulation outputs. Although the current framework does not yet explicitly model Doppler effects, its integration of traffic-level mobility with synchronized wireless and sensing modalities provides capabilities that are complementary to both standalone ray tracers and real-world dataset platforms.

# Software Design

Raymobtime combines mobility information, three-dimensional scenario representations, ray-tracing-based electromagnetic propagation, and sensing data to preserve the spatial and temporal evolution of simulated communication environments. Geographic information may be obtained from OpenStreetMap [@Haklay2008OpenStreetMap] and imported into Blender [@Blender] through the Blosm add-on [@Blosm] for scenario preparation and
three-dimensional modeling, while SUMO provides the trajectories and kinematic evolution of vehicles and other mobile entities
[@Krajzewicz2012SUMO].

The framework follows a modular orchestration architecture rather than reimplementing mobility, rendering, sensing, and propagation capabilities internally. This design allows specialized simulators to be integrated within a common configuration and dataset-generation workflow. When ray tracing is enabled, the scenario geometry and communication-node positions are provided to Wireless InSite to compute propagation paths and channel-related quantities [@WirelessInSite]. Compatible outputs from previously simulated runs can also be processed directly, avoiding unnecessary repetition of the computationally expensive ray-tracing stage. The architecture introduces a dependency on external software and, for complete ray-tracing execution, a proprietary Wireless InSite license. In return, individual stages can be independently enabled, replaced, or reused, improving extensibility and reducing recomputation.

The workflow also separates static and dynamic elements of the environment. Base-scenario files contain buildings and other fixed infrastructure, whereas mobile objects are repositioned across consecutive scenes according to trajectories generated by SUMO. This separation preserves temporal consistency without requiring reconstruction of the complete three-dimensional environment at every simulation step.

A Raymobtime dataset is organized into *episodes* containing temporally ordered *scenes*, as illustrated in \autoref{fig:episodes_scenes}. Consecutive scenes are sampled at interval $T_s$ and represent the evolving state of mobility, propagation, and sensing information. Receiver-to-entity assignments remain fixed within each episode while positions and surrounding conditions evolve across scenes, enabling temporally consistent analysis of problems such as beam tracking and channel prediction. Assignments may change between episodes to increase dataset diversity.

![Organization of scenes and episodes in Raymobtime. Each episode contains temporally ordered scenes sampled at intervals of $T_s$. Receiver-to-entity assignments remain fixed within an episode and may change between episodes, preserving temporal consistency while increasing dataset diversity.\label{fig:episodes_scenes}](Scene_Episodes.png){width=100%}

Each scene retains its simulation outputs and communication-node associations throughout data processing and post-processing. Consequently, coordinates, propagation information, RGB images, LiDAR scans, channel matrices, and beam labels remain associated with the same episode, scene, transmitter, and receiver context, keeping the generated modalities spatially and temporally synchronized.

\autoref{fig:raymobtime_flowchart} summarizes the execution workflow. Raymobtime can either process outputs from previously simulated runs or execute the enabled simulation stages before data processing and post-processing.

![Raymobtime execution workflow. Previously simulated run outputs can be processed directly without repeating the optional simulation steps. Alternatively, when the required external simulators and licenses are available, Raymobtime can execute the complete simulation pipeline to generate mobility, ray-tracing-based electromagnetic propagation, RGB, and LiDAR outputs. Both paths converge into data processing, post-processing, validation, and organization to produce the final synchronized multimodal dataset.\label{fig:raymobtime_flowchart}](RMT_pipeline.png){width=90%}

Simulation parameters, enabled modules, and requested outputs are defined through a shared configuration file. Raymobtime coordinates the required external tools and processing modules, while detailed configuration and output specifications are provided in the project documentation.

\autoref{fig:scenario_visualization} presents representative views from a Raymobtime urban scenario.

![Example visualization of a Raymobtime urban scenario. The figure illustrates different views of the same simulated environment, including receiver placement, transmitter--receiver associations, communication links, and the spatial organization of mobile and static objects.\label{fig:scenario_visualization}](camera_visualizations2.png){width=70%}

# Multimodal Output Organization

Raymobtime generates structured wireless and sensing representations while preserving their association with the corresponding episodes, scenes, transmitters, and receivers. The beam-processing stage reconstructs narrowband MIMO channel matrices from propagation paths and applies transmitter and receiver codebooks, producing beamformed channel responses and best-beam labels for beam-selection and machine-learning applications. Imported codebooks can be used, or DFT-based codebooks can be generated from the configured planar-array dimensions.

The sensing pipeline generates RGB images and LiDAR point clouds that can be further processed into refined images, receiver annotations, filtered point clouds, and voxelized representations. Because these outputs share the same simulation context, wireless and sensing modalities remain spatially and temporally aligned for communication, sensing, and multimodal learning applications.

# Research Impact Statement

Raymobtime has supported a growing body of research on data-driven wireless communications, with its datasets contributing to more than ten peer-reviewed journal and conference publications addressing problems including beam selection, multimodal beam selection, beam tracking, vehicle-to-vehicle communication, channel prediction, and ray-tracing-based MIMO channel generation [@KHATIBI2026103121]. Since its introduction, the publicly available datasets and scenarios have accumulated more than 1,000 downloads, reflecting their adoption by the wireless research community. A curated list of representative publications using Raymobtime datasets is maintained on the [project portal](https://raymobtime.lasseufpa.org/publications/).

Raymobtime has also contributed to international collaborative research initiatives. In the 2020 ITU Artificial Intelligence/Machine Learning in 5G Challenge, the Raymobtime s004 dataset supported the ML5G-PHY channel-estimation challenge, organized through collaboration involving researchers from UFPA, North Carolina State University, and the University of Texas at Austin. The challenge provided 10,000 ray-tracing-generated channels for training, together with additional channels for evaluation, allowing participants to investigate and compare data-driven and model-based approaches for site-specific mmWave MIMO channel estimation. Additional information is available on the [ITU AI/ML in 5G challenge website](https://research.ece.ncsu.edu/ai5gchallenge/).

The public collection currently comprises more than 20 outdoor, indoor, vehicle-to-infrastructure, vehicle-to-vehicle, and multimodal scenarios combining propagation, mobility, LiDAR, image, and position information.

# Software Availability and Licensing

Raymobtime is publicly available through its [GitHub repository](https://github.com/lasseufpa/Raymobtime) under the GNU General Public License v3.0 (GPL-3.0). The release associated with this paper is archived at Zenodo (DOI: [10.5281/zenodo.22030040](https://doi.org/10.5281/zenodo.22030040)).

Installation instructions, scenario-creation tutorials, dataset-generation documentation, output-format descriptions, and contribution guidelines are provided in the repository. Generated datasets and related publications are available through the Raymobtime project portal.

**Observation.** Complete ray-tracing execution requires a licensed Wireless InSite installation, although previously generated compatible propagation outputs can be processed without rerunning this stage.

# AI Usage Disclosure

Generative AI tools were used to assist with language editing and manuscript restructuring. All technical descriptions, software claims, references, and proposed revisions were reviewed by the authors against the source code, project documentation, and generated outputs. The authors remain responsible for the correctness and final content of the manuscript.

# Acknowledgements

This work was funded by the Smart 5G Core and Multi-RAN Integration (SAMURAI) Project under FAPESP Grant 2020/05127-2. The funding agency had no role in the software design, analysis, or preparation of this manuscript.

# References
