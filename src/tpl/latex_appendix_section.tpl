\clearpage
\subsubsection{%%longname%%}

Basert på \num{%%doc_count%%} dokumenter publisert i Offentlig Elektronisk
Postjournal av %%longname|strtolower()%%.

\begin{figure}[H]
\hspace{-0.04\textwidth}
\includegraphics[width=1.04\textwidth]{timeline_median_%%id_supplier%%_io}
\caption{Medgåtte virkedager i median mellom dokumentdato, journaldato og publiseringsdato for %%longname|strtolower()%%. Periodisert månedsvis etter dokumentdato.}
\centering
\label{timeline_median_%%id_supplier%%_io}
\end{figure}
\begin{figure}[H]
\centering
\begin{minipage}{.5\textwidth}
  \centering
  \includegraphics[width=.9\linewidth]{timeline_median_%%id_supplier%%_i_small}
  \emph{Inngående korrespondanse}
\end{minipage}%
\begin{minipage}{.5\textwidth}
  \includegraphics[width=.9\linewidth]{timeline_median_%%id_supplier%%_o_small}
  \centering
  \emph{Utgående korrespondanse}
\end{minipage}
\caption{Samme som over, men fordelt på inngående og utgående dokumenter. Medgåtte virkedager i median mellom dokumentdato, journaldato og publiseringdato.}
\end{figure}

\begin{figure}[H]
\hspace{-0.04\textwidth}
\includegraphics[width=1.04\textwidth]{timeline_mean_%%id_supplier%%_io}
\caption{Medgåtte virkedager i gjennomsnitt mellom dokumentdato, journaldato og publiseringsdato for %%longname|strtolower()%%. Periodisert månedsvis etter dokumentdato.}
\centering
\label{timeline_mean_%%id_supplier%%_io}
\end{figure}
\begin{figure}[H]
\centering
\begin{minipage}{.5\textwidth}
  \centering
  \includegraphics[width=.9\linewidth]{timeline_mean_%%id_supplier%%_i_small}
  \emph{Inngående korrespondanse}
\end{minipage}%
\begin{minipage}{.5\textwidth}
  \includegraphics[width=.9\linewidth]{timeline_mean_%%id_supplier%%_o_small}
  \centering
  \emph{Utgående korrespondanse}
\end{minipage}
\caption{Samme som over, men fordelt på inngående og utgående dokumenter. Medgåtte virkedager i gjennomsnitt mellom dokumentdato, journaldato og publiseringdato.}
\end{figure}

Dersom rutinene for publisering fra et organ ligger fast og skjer etter et relativt
regelmessig antall virkedager, kan vi forvente lavt standarddavvik for perioden
journaldato $\rightarrow$ publiseringsdato.

\begin{figure}[H]
\begin{tabu} to \textwidth { Xr }
 	\textbf{Intervall} & \textbf{Standardavvik}\\
 	\midrule
		\raisebox{0.7mm}{\colorbox{doc2jour}{\makebox(8,2){ }}} Dokumentdato $\rightarrow$ journaldato & %%stddev_doc2jour%% virkedager\\
		\raisebox{0.7mm}{\colorbox{jour2pub}{\makebox(8,2){ }}} Journaldato $\rightarrow$ publiseringsdato & %%stddev_jour2pub%% virkedager\\
\end{tabu}
\caption{Standardavvik i antall virkedager fra gjennomsnittet, %%longname|strtolower()%%. Fra januar 2014 til høsten 2016. Høye verdier indikerer større variasjoner i tidsbruken.}
\end{figure}
