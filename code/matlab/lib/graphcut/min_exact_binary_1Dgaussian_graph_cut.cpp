/* MIN_EXACTE_BINAIRE_GRAPH_CUT  algo de Greig
 *
 * Usage: Ir=min_exacte_binary_1Dgaussian_graph_cut(I,v1,v2,beta);
 
 */


#include "mex.h"
#include "math.h"

#include "graph.h"
#include "graph.cpp"
#include "maxflow.cpp"

//evaluate the value of a mixture of N componant on x
double evaluate_mixture(double x, double* mu, double* sigma, double* pi, long N)
{
	double res=0;
	for (int i =0;i<N;i++)
	{
		double g=pi[i]/sqrt(2*3.14*sigma[i])*exp(-0.5*(x-mu[i])*(x-mu[i])/sigma[i]);
		res+=(g);
	}
	return res;  
}

// Terme d'attache aux données
double attache_aux_donnees(double noisy, double * m, long N)
{
  /* a completer par l'energie d'attache aux donnees souhaitee */
    double * mu, * sigma, * pi;
    pi=m;
    mu=m+N;
    sigma=mu+N;
    return log(evaluate_mixture(noisy, mu, sigma, pi, N)) ;
}


// Message d'erreur
void error_msg(char * msg)
{
    mexWarnMsgTxt("Erreur!");
    mexWarnMsgTxt("Usage: Ir=min_exacte_binaire_graph_cut(I,v1,v2,beta)");
    mexErrMsgTxt(msg);
}

// Algorithme graph-cut proprement dit
void compute_graph_cut(double * Id, double * Ir, long W, long H, double * m1, double * m2, long N, double beta, double gamma)
{
  long Npix=W*H;
  // Fonction à compléter...
    
         
  /* Allocation du graphe */
     // instancier un objet de type graphe
  //Graph g(Npix,2*Npix,error_msg);
  
  // ou
  Graph* g = new Graph(Npix,2*Npix,error_msg);
    if(g==NULL)
        error_msg("Memory allocation for the graph failed!");
     

    // allouer le tableau d'identifiants de noeuds
    Graph::node_id *nodes=new Graph::node_id[Npix];
    if(nodes==NULL)
        error_msg("Memory allocation failed! (array of nodes could not be created)");
  
    
        
  /* Construction du graphe */
    
    // Création des noeuds
    for(long i=0; i<Npix; i++)
        nodes[i]=g->add_node();

        
    
    // Création des arcs
    for(long i=0; i<W; i++)
    {
        long offset=i*H;
        for(long j=0; j<H; j++)
        {
            long pix=offset+j; // coordonnée linéaire du pixel courant
            
            // Termes d'attache aux données
            double E1=attache_aux_donnees(Id[pix],m1,N);    // -log vraisemblance de v1
            double E2=attache_aux_donnees(Id[pix],m2,N);    // -log vraisemblance de v2
            
            g->add_tweights(nodes[pix],E2,E1);

            // Termes de régularisation
            if(j<H-1)
		{
		double diff=abs(Id[pix]-Id[pix+1]);
		double vpq=gamma*exp(-beta*diff);
                g->add_edge(nodes[pix],nodes[pix+1],vpq,vpq);
		}
            if(i<W-1)
		{
		double diff=abs(Id[pix]-Id[pix+H]);
		double vpq=gamma*exp(-beta*diff);
                g->add_edge(nodes[pix],nodes[pix+H],vpq,vpq);
		}
        }
    }
    
        
  /* Calcul de la coupe minimale */
    g->maxflow();
    
    
    
  /* Déduction de l'image régularisée */
    for(long pix=0; pix<Npix; pix++)
    {
        // si le noeud n'est plus relié à la source, c'est qu'il faut associer
        // la valeur 1 au pixel correspondant dans l'image régularisée
        if(g->what_segment(nodes[pix])!=(Graph::SOURCE))
            Ir[pix]=1;
        else
            Ir[pix]=0;
    }


    
  /* Libération mémoire */
    
    delete g;
    delete nodes;


}


// Fonction principale (gère la liaison avec Matlab)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
const mxArray *prhs[])
{
  /* Vérification du nombre d'arguments */
    if ( nrhs != 5 ) {
        error_msg("Nombre d'arguments d'entrée incorrect!");
    } else if ((nlhs != 1)) {
        error_msg("Nombre d'arguments de sortie incorrect!");
    }
    
  /* Vérification du type des arguments */
    if (!mxIsDouble(prhs[0])||mxIsComplex(prhs[0])||
    !mxIsDouble(prhs[1])||mxIsComplex(prhs[1])||mxGetN(prhs[1])!=3||
    !mxIsDouble(prhs[2])||mxIsComplex(prhs[2])||
    !mxIsDouble(prhs[3])||mxIsComplex(prhs[3])||mxGetM(prhs[3])!=1||mxGetN(prhs[3])!=1||
    !mxIsDouble(prhs[4])||mxIsComplex(prhs[4])||mxGetM(prhs[4])!=1||mxGetN(prhs[4])!=1
    ) {
        error_msg("Mauvais type d'argument!");
    }
    
    long W,H,N;
    W = mxGetM(prhs[0]);
    H = mxGetN(prhs[0]);
    N = mxGetM(prhs[1]);

  /* On récupère les paramètres scalaires */
    double beta,gamma;
    beta=*mxGetPr(prhs[3]);
    gamma=*mxGetPr(prhs[4]);
    
    
  /* On crée l'image de sortie */
    plhs[0] = mxCreateDoubleMatrix(W,H, mxREAL);
    
  /* On récupère les adresses des matrices d'entrée et de sortie et les mixture*/
    double *Id, *Ir, *m1, *m2;
    
    Id = mxGetPr(prhs[0]);
    m1 = mxGetPr(prhs[1]);
    m2 = mxGetPr(prhs[2]);

    Ir = mxGetPr(plhs[0]);
    compute_graph_cut(Id,Ir,W,H,m1,m2,N,beta,gamma);
}
