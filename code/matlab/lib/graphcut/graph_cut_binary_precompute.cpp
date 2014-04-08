/* MIN_EXACTE_BINAIRE_GRAPH_CUT  algo de Greig
 *
 * Usage: Ir=min_exacte_binary_1Dgaussian_graph_cut(I,v1,v2,beta);
 
 */


#include "mex.h"
#include "math.h"

#include "graph.h"
#include "graph.cpp"
#include "maxflow.cpp"

// Message d'erreur
void error_msg(char * msg)
{
    mexWarnMsgTxt("Erreur!");
    mexWarnMsgTxt("Usage: Ir=min_exacte_binaire_graph_cut(I,v1,v2,beta)");
    mexErrMsgTxt(msg);
}

// Algorithme graph-cut proprement dit
//compute_graph_cut(Ir,back_likely,for_likely,dx,dy,W,H,beta,gamma)
void compute_graph_cut(double * Ir, double * back_likely, double * for_likely, double * dx, double * dy, long W, long H, double beta, double gamma)
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
            double E1=back_likely[pix];    // -log vraisemblance de v1
            double E2=for_likely[pix];    // -log vraisemblance de v2
            
            g->add_tweights(nodes[pix],E2,E1);

            // Termes de régularisation
            if(j<H-1)
		{
		double diff=dy[pix];
		double vpq=gamma*exp(-beta*diff);
                g->add_edge(nodes[pix],nodes[pix+1],vpq,vpq);
		}
            if(i<W-1)
		{
		double diff=dx[pix];
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
    if ( nrhs != 6 ) {
        error_msg("Nombre d'arguments d'entrée incorrect!");
    } else if ((nlhs != 1)) {
        error_msg("Nombre d'arguments de sortie incorrect!");
    }
    
  /* Vérification du type des arguments */
    if (
    !mxIsDouble(prhs[0])||mxIsComplex(prhs[0])||//back_likely
    !mxIsDouble(prhs[1])||mxIsComplex(prhs[1])||//for_likely
    !mxIsDouble(prhs[2])||mxIsComplex(prhs[2])||//dx
    !mxIsDouble(prhs[3])||mxIsComplex(prhs[3])||//dy
    !mxIsDouble(prhs[4])||mxIsComplex(prhs[4])||mxGetM(prhs[4])!=1||mxGetN(prhs[4])!=1||//beta
    !mxIsDouble(prhs[5])||mxIsComplex(prhs[5])||mxGetM(prhs[5])!=1||mxGetN(prhs[5])!=1//gamma
    ) {
        error_msg("Mauvais type d'argument!");
    }
    
    long W,H,N;
    W = mxGetN(prhs[0]);//mxGetN :Number of columm in array
    H = mxGetM(prhs[0]);//mxGetM : Number of rows in array

  /* On récupère les paramètres scalaires */
    double beta,gamma;
    beta=*mxGetPr(prhs[4]);
    gamma=*mxGetPr(prhs[5]);
    
    
  /* On crée l'image de sortie */
    plhs[0] = mxCreateDoubleMatrix(H,W, mxREAL);
    
  /* On récupère les adresses des matrices d'entrée et de sortie et les mixture*/
    double *back_likely, *for_likely, *Ir, *dx, *dy;
    
    back_likely = mxGetPr(prhs[0]);
    for_likely = mxGetPr(prhs[1]);
    dx = mxGetPr(prhs[2]);
    dy = mxGetPr(prhs[3]);

    Ir = mxGetPr(plhs[0]);
    compute_graph_cut(Ir,back_likely,for_likely,dx,dy,W,H,beta,gamma);
}
